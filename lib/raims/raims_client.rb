# frozen_string_literal: true

require 'uri'
require 'ipaddr'
require 'time'
require 'thread'

module Raims
  class RaimsClient
    MAX_RESPONSE_BYTES = 16 * 1024 * 1024
    RETRY_STATUSES = [408, 429, 500, 502, 503, 504].freeze
    ERROR_CLASSES = {400 => InvalidRequestError, 405 => InvalidRequestError, 413 => InvalidRequestError,
                     415 => InvalidRequestError, 422 => InvalidRequestError, 401 => AuthenticationError,
                     403 => PermissionError, 404 => NotFoundError, 409 => ConflictError, 429 => RateLimitError}.freeze

    attr_reader :accounts, :balances, :charges, :customers, :disputes, :payment_links,
                :refunds, :statements, :withdrawals, :withdrawal_destinations,
                :webhooks, :webhook_event_types, :simulations

    def initialize(api_key, api_base: 'https://api.raims.com', timeout: 80, connect_timeout: 10,
                   max_network_retries: 0, http_client: nil, request_observer: nil)
      @api_key = Util.visible_ascii(api_key, 4096, 'api_key')
      @api_base = validate_base(api_base)
      @timeout = Util.timeout(timeout)
      @connect_timeout = Util.timeout(connect_timeout)
      @max_network_retries = Util.retries(max_network_retries)
      raise ArgumentError, 'request_observer must respond to call.' if request_observer && !request_observer.respond_to?(:call)
      @observer = request_observer
      @http_client = http_client || NetHttpClient.new
      raise ArgumentError, 'http_client must respond to execute.' unless @http_client.respond_to?(:execute)
      @mutex = Mutex.new
      @condition = ConditionVariable.new
      @closed = false
      @notifying = {}
      Schema::CONTRACT.fetch('services').each_key do |name|
        next if name.start_with?('simulation_')
        klass = name.split('_').map(&:capitalize).join + 'Service'
        instance_variable_set("@#{name}", Raims.const_get(klass, false).new(self))
      end
      @simulations = SimulationsService.new(self)
    end

    def self.open(api_key, **options)
      client = new(api_key, **options)
      return client unless block_given?
      begin
        yield client
      ensure
        client.close
      end
    end

    def close
      @mutex.synchronize do
        return if @closed
        @closed = true
        @condition.broadcast
      end
      nil
    end

    def closed?
      @mutex.synchronize { @closed }
    end

    def inspect
      "#<#{self.class} version=#{VERSION} closed=#{closed?}>"
    end
    alias to_s inspect

    def request(operation_id, path_params: {}, params: {}, options: {})
      check_open
      operation = Schema::CONTRACT.fetch('operations') { raise ArgumentError, 'Unknown SDK operation.' }.fetch(operation_id) { raise ArgumentError, 'Unknown SDK operation.' }
      options = RequestOptions.coerce(options)
      if options.idempotency_key && !operation['idempotency']
        raise ArgumentError, 'This operation does not accept an idempotency key.'
      end
      unless path_params.is_a?(Hash) && path_params.keys.sort == operation.fetch('pathParams').sort
        raise ArgumentError, 'The operation received invalid path parameters.'
      end
      path = operation.fetch('path').dup
      path_snapshot = {}
      path_params.each do |name, value|
        value = value.dup if value.is_a?(String)
        unless value.is_a?(String) && value.ascii_only? && value.match?(/\A[A-Za-z0-9_-]+\z/)
          raise ArgumentError, 'Resource identifiers must be non-empty URL-safe strings.'
        end
        path_snapshot[name.dup.freeze] = value.freeze
        path.gsub!("{#{name}}", value)
      end
      path_params = path_snapshot.freeze
      raise ArgumentError, 'params must be a Hash.' unless params.is_a?(Hash)
      snapshot = Util.json_value(params)
      if operation['paginated'] && !snapshot['after'].nil? && !snapshot['before'].nil?
        raise ArgumentError, 'after and before cannot be used together.'
      end
      headers = {'Authorization' => "Bearer #{options.api_key || @api_key}", 'Accept' => 'application/json', 'User-Agent' => "raims-ruby/#{VERSION}"}
      headers['Idempotency-Key'] = options.idempotency_key if options.idempotency_key
      body = nil
      if operation['body']
        body = JSON.generate(snapshot, max_nesting: 100, allow_nan: false)
        if operation['maxBodyBytes'] && body.bytesize > operation['maxBodyBytes']
          raise ArgumentError, 'Request body exceeds the published size limit.'
        end
        headers['Content-Type'] = 'application/json'
      else
        query = []
        snapshot.each do |key, value|
          raise ArgumentError, 'This operation received an unsupported query parameter or body.' unless operation.fetch('query').key?(key)
          next if value.nil?
          (value.is_a?(Array) ? value : [value]).each do |child|
            unless child.is_a?(String) || child.is_a?(Integer) || child.is_a?(Float) || child == true || child == false
              raise ArgumentError, 'Query values must be scalars or lists of scalars.'
            end
            query << [key, child.to_s]
          end
        end
        path += '?' + URI.encode_www_form(query) unless query.empty?
      end
      uri = URI.parse(@api_base + path)
      timeout = options.timeout || @timeout
      retries = %w[GET HEAD].include?(operation['method']) ? (options.max_network_retries || @max_network_retries) : 0
      attempt = 0
      loop do
        check_open
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        metadata = nil
        error = nil
        result = nil
        begin
          raw = @http_client.execute(method: operation['method'], uri: uri.dup,
                                     headers: headers.dup, body: body&.dup, timeout: timeout,
                                     connect_timeout: [timeout, @connect_timeout].min,
                                     max_response_bytes: MAX_RESPONSE_BYTES)
          unless raw.is_a?(HttpResponse) && raw.status.is_a?(Integer) && (100..599).cover?(raw.status) && raw.headers.is_a?(Hash) && raw.body.is_a?(String)
            raise UnexpectedResponseError, 'The HTTP transport returned an invalid response.'
          end
          metadata = ApiResponse.new(raw.status, raw.headers)
          if raw.body.bytesize > MAX_RESPONSE_BYTES
            raise UnexpectedResponseError.new('The API response exceeds the supported size.', last_response: metadata)
          end
          result = interpret(raw.body, metadata, operation, path_params, snapshot, options)
        rescue RaimsError => failure
          error = failure
          metadata ||= failure.last_response
        rescue Zlib::Error
          error = UnexpectedResponseError.new('The API returned invalid compressed content.')
        rescue Net::HTTPHeaderSyntaxError
          error = UnexpectedResponseError.new('The API returned invalid HTTP headers.')
        rescue IOError, SystemCallError, Timeout::Error, SocketError, OpenSSL::SSL::SSLError, Net::HTTPBadResponse, Net::ProtocolError
          error = ConnectionError.new('Could not complete the API request. A write may have been processed; reconcile before retrying.')
        end
        delay = nil
        if error && attempt < retries && (error.is_a?(ConnectionError) || error.is_a?(ApiError) && RETRY_STATUSES.include?(metadata&.status_code))
          delay = retry_delay(attempt, metadata)
        end
        notify(operation, attempt, started, metadata, delay)
        raise error, cause: nil if error && delay.nil?
        return result unless error
        @mutex.synchronize do
          raise ConnectionError, 'The SDK client is closed.' if @closed
          deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + delay
          loop do
            remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
            break if remaining <= 0
            @condition.wait(@mutex, remaining)
            raise ConnectionError, 'The SDK client is closed.' if @closed
          end
        end
        attempt += 1
      end
    end

    private

    def check_open
      raise ConnectionError, 'The SDK client is closed.' if closed?
    end

    def validate_base(value)
      unless value.is_a?(String) && value.ascii_only? && !value.match?(/[\x00-\x20\x7f\\?#]/)
        raise ArgumentError, 'api_base must be an HTTPS origin.'
      end
      uri = URI.parse(value)
      loopback = uri.hostname == 'localhost'
      begin
        loopback ||= IPAddr.new(uri.hostname).loopback?
      rescue IPAddr::InvalidAddressError, ArgumentError
        loopback = false unless loopback
      end
      unless uri.is_a?(URI::HTTP) && uri.hostname && !uri.userinfo && ['', '/'].include?(uri.path) && uri.port.positive? && uri.port <= 65_535 && (uri.scheme == 'https' || uri.scheme == 'http' && loopback)
        raise ArgumentError, 'api_base requires HTTPS without credentials or a path; HTTP is allowed only on loopback.'
      end
      value.delete_suffix('/').freeze
    rescue URI::InvalidURIError
      raise ArgumentError, 'api_base must be an HTTPS origin.', cause: nil
    end

    def retry_delay(attempt, metadata)
      delay = [2.0, 0.5 * (2**attempt)].min * (0.5 + rand * 0.5)
      header = metadata&.retry_after
      if header
        begin
          wanted = header.strip.match?(/\A\d+\z/) ? header.to_i : Time.httpdate(header).to_f - Time.now.to_f
          return nil if wanted > 30
          delay = [delay, wanted].max
        rescue ArgumentError
          # Invalid server hints do not override the bounded backoff.
        end
      end
      delay
    end

    def notify(operation, attempt, started, metadata, delay)
      return unless @observer
      context = Fiber.current
      allowed = @mutex.synchronize do
        if @notifying[context]
          false
        else
          @notifying[context] = true
        end
      end
      return unless allowed
      begin
        @observer.call(RequestDiagnostics.new(operation_id: operation['id'], method: operation['method'], path: operation['path'],
                                             attempt: attempt + 1, duration_ms: (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000,
                                             status_code: metadata&.status_code, request_id: metadata&.request_id,
                                             will_retry: !delay.nil?, retry_delay_ms: delay && delay * 1000))
      rescue StandardError
        # Diagnostics must not change the outcome of a financial request.
      ensure
        @mutex.synchronize { @notifying.delete(context) }
      end
    end

    def interpret(body, metadata, operation, path_params, params, options)
      status = metadata.status_code
      if (300..399).cover?(status)
        raise UnexpectedResponseError.new('The API returned a redirect; redirects are not followed.', last_response: metadata)
      end
      unless (200..299).cover?(status)
        api_error = nil
        begin
          parsed = Util.parse_json(body)
          api_error = parsed['error'] if parsed.is_a?(Hash) && parsed['error'].is_a?(Hash)
        rescue JSON::ParserError, ArgumentError
          # Preserve HTTP failures when an intermediary returns non-JSON content.
        end
        raise ERROR_CLASSES.fetch(status, ApiError).new("The API request failed with HTTP #{status}.", last_response: metadata, api_error: api_error)
      end
      responses = operation.fetch('responses')
      unless responses.key?(status.to_s)
        raise UnexpectedResponseError.new('The API returned an undocumented success status.', last_response: metadata)
      end
      schema = responses[status.to_s]
      if schema.nil?
        raise UnexpectedResponseError.new('The API returned a body for an empty response.', last_response: metadata) unless body.empty?
        return nil
      end
      content_type = metadata.headers['content-type']
      if content_type && !content_type.match?(/\Aapplication\/(?:[a-z0-9.+-]+\+)?json(?:\s*;|\z)/i)
        raise UnexpectedResponseError.new('The API returned a non-JSON success response.', last_response: metadata)
      end
      begin
        data = Util.parse_json(body)
      rescue JSON::ParserError, ArgumentError
        raise UnexpectedResponseError.new('The API returned invalid JSON.', last_response: metadata), cause: nil
      end
      Schema.validate(data, schema, metadata)
      resource = Schema.hydrate(data, schema, metadata)
      return resource unless operation['paginated']
      ApiList.new(resource, client: self, operation_id: operation['id'], path_params: path_params, params: params, options: options)
    end
  end
end

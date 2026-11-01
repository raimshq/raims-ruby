# frozen_string_literal: true

module Raims
  class RequestOptions
    attr_reader :api_key, :idempotency_key, :timeout, :max_network_retries

    def initialize(api_key: nil, idempotency_key: nil, timeout: nil, max_network_retries: nil)
      @api_key = Util.visible_ascii(api_key, 4096, 'api_key') unless api_key.nil?
      @idempotency_key = Util.visible_ascii(idempotency_key, 255, 'idempotency_key') unless idempotency_key.nil?
      @timeout = Util.timeout(timeout) unless timeout.nil?
      @max_network_retries = Util.retries(max_network_retries) unless max_network_retries.nil?
      freeze
    end

    def self.coerce(value)
      return value if value.is_a?(self)
      raise ArgumentError, 'options must be a Hash or RequestOptions.' unless value.is_a?(Hash)
      mapped = value.each_with_object({}) do |(key, child), result|
        unless %w[api_key idempotency_key timeout max_network_retries].include?(key.to_s) && !result.key?(key.to_s.to_sym)
          raise ArgumentError, 'Request options contain an unsupported or duplicate field.'
        end
        result[key.to_s.to_sym] = child
      end
      new(**mapped)
    end

    def inspect
      "#<#{self.class}>"
    end
    alias to_s inspect
  end

  class RequestDiagnostics
    attr_reader :operation_id, :method, :path, :attempt, :duration_ms,
                :status_code, :request_id, :will_retry, :retry_delay_ms

    def initialize(**fields)
      fields.each { |key, value| instance_variable_set("@#{key}", value.is_a?(String) ? value.dup.freeze : value) }
      freeze
    end

    def inspect
      "#<#{self.class} operation_id=#{operation_id} attempt=#{attempt} status_code=#{status_code.inspect}>"
    end
    alias to_s inspect
  end
end

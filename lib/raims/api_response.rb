# frozen_string_literal: true

module Raims
  class ApiResponse
    attr_reader :status_code, :headers

    def initialize(status_code, headers = {})
      @status_code = status_code
      @headers = Util.deep_freeze(headers.each_with_object({}) { |(key, value), result| result[key.to_s.downcase] = value.to_s.dup })
      freeze
    end

    def request_id
      headers['request-id']
    end

    def retry_after
      headers['retry-after']
    end

    def idempotency_replayed?
      headers.fetch('idempotency-replayed', '').casecmp?('true')
    end

    def inspect
      "#<#{self.class} status_code=#{status_code}>"
    end
    alias to_s inspect
  end

  class HttpResponse
    attr_reader :status, :headers, :body

    def initialize(status:, headers:, body:)
      @status = status
      @headers = headers
      @body = body
    end

    def inspect
      "#<#{self.class} status=#{status}>"
    end
    alias to_s inspect
  end
end

# frozen_string_literal: true

module Raims
  class RaimsError < StandardError
    attr_reader :last_response, :api_error

    def initialize(message, last_response: nil, api_error: nil)
      super(message)
      @last_response = last_response
      @api_error = api_error && Util.deep_freeze(api_error)
    end

    def http_status
      last_response&.status_code
    end
    alias status_code http_status

    def request_id
      last_response&.request_id
    end

    def retry_after
      last_response&.retry_after
    end

    def code
      value = api_error && api_error['code']
      value if value.is_a?(String)
    end

    def api_message
      value = api_error && api_error['message']
      value if value.is_a?(String)
    end

    def details
      value = api_error && api_error['details']
      value if value.is_a?(Array)
    end

    def inspect
      "#<#{self.class} http_status=#{http_status.inspect}>"
    end
  end

  class ApiError < RaimsError; end
  class AuthenticationError < ApiError; end
  class PermissionError < ApiError; end
  class NotFoundError < ApiError; end
  class InvalidRequestError < ApiError; end
  class ConflictError < ApiError; end
  class RateLimitError < ApiError; end
  class ConnectionError < RaimsError; end
  class UnexpectedResponseError < RaimsError; end
  class SignatureVerificationError < RaimsError; end
end

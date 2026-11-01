# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'timeout'
require 'zlib'

module Raims
  class NetHttpClient
    def execute(method:, uri:, headers:, body:, timeout:, connect_timeout:, max_response_bytes:)
      # An explicit nil proxy disables environment proxy discovery.
      http = Net::HTTP.new(uri.hostname, uri.port, nil)
      http.use_ssl = uri.scheme == 'https'
      if http.use_ssl?
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.min_version = OpenSSL::SSL::TLS1_2_VERSION
      end
      http.open_timeout = [timeout, connect_timeout].min
      http.read_timeout = timeout
      http.write_timeout = timeout
      http.max_retries = 0
      request = Net::HTTPGenericRequest.new(method, !body.nil?, method != 'HEAD', uri.request_uri, headers)
      request.body = body unless body.nil?
      result = nil
      metadata = nil
      Timeout.timeout(timeout) do
        http.start do |connection|
          connection.request(request) do |response|
            metadata = ApiResponse.new(response.code.to_i, response.each_header.to_h)
            length = content_length(response, metadata)
            validate_transfer_encoding(response, length, metadata)
            response.ignore_eof = false
            response.content_length = length unless length.nil?
            has_body = method != 'HEAD' && response.class.body_permitted?
            if has_body && length && length > max_response_bytes
              raise UnexpectedResponseError.new('The API response exceeds the supported size.', last_response: metadata)
            end
            bytes = String.new(encoding: Encoding::BINARY)
            begin
              response.read_body do |chunk|
                if bytes.bytesize + chunk.bytesize > max_response_bytes
                  raise UnexpectedResponseError.new('The API response exceeds the supported size.', last_response: metadata)
                end
                bytes << chunk
              end
            rescue EOFError
              raise UnexpectedResponseError.new('The API response ended before the HTTP body was complete.', last_response: metadata), cause: nil
            rescue Net::HTTPBadResponse
              raise UnexpectedResponseError.new('The API returned invalid HTTP body framing.', last_response: metadata), cause: nil
            end
            result = HttpResponse.new(status: metadata.status_code, headers: metadata.headers, body: bytes)
          end
        end
      end
      result
    rescue Zlib::Error
      raise UnexpectedResponseError.new('The API returned invalid compressed content.', last_response: metadata), cause: nil
    rescue Net::HTTPHeaderSyntaxError
      raise UnexpectedResponseError.new('The API returned invalid HTTP headers.', last_response: metadata), cause: nil
    end

    def inspect
      "#<#{self.class}>"
    end
    alias to_s inspect

    private

    def content_length(response, metadata)
      fields = response.get_fields('content-length')
      return nil unless fields
      values = fields.flat_map { |field| field.split(',', -1) }
      unless !values.empty? && values.all? { |value| value.match?(/\A[ \t]*[0-9]+[ \t]*\z/) }
        raise UnexpectedResponseError.new('The API returned an invalid Content-Length header.', last_response: metadata)
      end
      lengths = values.map(&:to_i).uniq
      unless lengths.length == 1
        raise UnexpectedResponseError.new('The API returned conflicting Content-Length headers.', last_response: metadata)
      end
      lengths.first
    end

    def validate_transfer_encoding(response, length, metadata)
      fields = response.get_fields('transfer-encoding')
      return unless fields
      unless length.nil? && fields.length == 1 && fields.first.match?(/\A[ \t]*chunked[ \t]*\z/i)
        raise UnexpectedResponseError.new('The API returned unsupported or ambiguous HTTP transfer framing.', last_response: metadata)
      end
    end
  end
end

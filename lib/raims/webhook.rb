# frozen_string_literal: true

require 'openssl'

module Raims
  class Webhook
    ALPHABET = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

    def self.verify_signature(payload, headers, secret, tolerance: 300, now: nil)
      raise ArgumentError, 'Webhook tolerance must be a non-negative integer.' unless tolerance.is_a?(Integer) && tolerance >= 0
      current = now.nil? ? Time.now.to_i : now
      raise ArgumentError, 'Webhook now must be a non-negative integer.' unless current.is_a?(Integer) && current >= 0
      raise SignatureVerificationError, 'The webhook body must contain the original HTTP bytes.' unless payload.is_a?(String)
      delivery = header(headers, 'webhook-id')
      timestamp = header(headers, 'webhook-timestamp')
      signatures = header(headers, 'webhook-signature')
      unless delivery.match?(/\A[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}\z/)
        raise SignatureVerificationError, 'The webhook delivery ID is invalid.'
      end
      unless timestamp.match?(/\A[0-9]{1,12}\z/) && (timestamp.to_i - current).abs <= tolerance
        raise SignatureVerificationError, 'The webhook timestamp is invalid or outside tolerance.'
      end
      key = decode_secret(secret)
      expected = OpenSSL::HMAC.digest('SHA256', key, "#{delivery}.#{timestamp}.".b + payload.b)
      matched = false
      signatures.split(',').each do |candidate|
        match = candidate.strip.match(/\Av1=([0-9a-fA-F]{64})\z/i)
        next unless match
        valid = OpenSSL.fixed_length_secure_compare(expected, [match[1]].pack('H*'))
        matched = true if valid
      end
      raise SignatureVerificationError, 'No webhook signature matches the configured secret.' unless matched
      nil
    end

    def self.construct_event(payload, headers, secret, tolerance: 300, now: nil)
      verify_signature(payload, headers, secret, tolerance: tolerance, now: now)
      begin
        event = Util.parse_json(payload)
      rescue JSON::ParserError, ArgumentError
        raise SignatureVerificationError, 'The authenticated webhook body is not valid JSON.', cause: nil
      end
      raise SignatureVerificationError, 'The authenticated webhook body must be a JSON object.' unless event.is_a?(Hash)
      event
    end

    def self.header(headers, name)
      raise SignatureVerificationError, 'Webhook headers must be a Hash.' unless headers.is_a?(Hash)
      values = headers.select { |key, _value| key.is_a?(String) && key.downcase == name }.values
      raise SignatureVerificationError, 'A webhook signing header is missing or duplicated.' unless values.length == 1
      value = values.first
      value = value.first if value.is_a?(Array) && value.length == 1
      unless value.is_a?(String) && value.ascii_only? && !value.empty? && !value.match?(/[\x00-\x08\x0a-\x1f\x7f]/)
        raise SignatureVerificationError, 'A webhook signing header is invalid.'
      end
      value
    end
    private_class_method :header

    def self.decode_secret(secret)
      unless secret.is_a?(String) && secret.ascii_only? && secret.match?(/\Awhsec_[0-9A-Za-z]{1,43}\z/)
        raise SignatureVerificationError, 'The webhook signing secret is invalid.'
      end
      encoded = secret.delete_prefix('whsec_')
      raise SignatureVerificationError, 'The webhook signing secret is invalid.' if encoded.length > 1 && encoded.start_with?('0')
      number = encoded.each_char.reduce(0) { |value, char| value * 62 + ALPHABET.index(char) }
      raise SignatureVerificationError, 'The webhook signing secret is invalid.' if number >= (1 << 256)
      Array.new(32) { |index| (number >> (index * 8)) & 255 }.pack('C*')
    end
    private_class_method :decode_secret
  end
end

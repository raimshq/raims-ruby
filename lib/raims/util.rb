# frozen_string_literal: true

require 'json'
require 'bigdecimal'

module Raims
  module Util
    MAX_DECIMAL_EXPONENT = 4300

    class JsonDecimal
      def self.new(token)
        Util.parse_decimal(token)
      end
    end
    private_constant :JsonDecimal

    module_function

    def visible_ascii(value, maximum, label)
      unless value.is_a?(String) && value.ascii_only? && value.match?(/\A[\x21-\x7e]{1,#{maximum}}\z/)
        raise ArgumentError, "#{label} must contain visible ASCII without spaces."
      end
      value.dup.freeze
    end

    def timeout(value)
      unless (value.is_a?(Integer) || value.is_a?(Float)) && value.finite? && value.positive? && value <= 300
        raise ArgumentError, 'timeout must be greater than zero and at most 300 seconds.'
      end
      value.to_f
    end

    def retries(value)
      raise ArgumentError, 'max_network_retries must be an integer between zero and five.' unless value.is_a?(Integer) && (0..5).cover?(value)
      value
    end

    def deep_freeze(value)
      case value
      when Hash
        value.each { |key, child| deep_freeze(key); deep_freeze(child) }
      when Array
        value.each { |child| deep_freeze(child) }
      end
      value.freeze
    end

    def json_value(value, seen = {}, depth = 0)
      raise ArgumentError, 'Request parameters are nested too deeply.' if depth > 100
      case value
      when Hash, Array
        raise ArgumentError, 'Request parameters cannot contain cycles.' if seen[value.object_id]
        seen[value.object_id] = true
        begin
          if value.is_a?(Array)
            value.map { |child| json_value(child, seen, depth + 1) }
          else
            value.each_with_object({}) do |(key, child), result|
              raise ArgumentError, 'JSON field names must be strings or symbols.' unless key.is_a?(String) || key.is_a?(Symbol)
              key = utf8_string(key.to_s)
              raise ArgumentError, 'JSON field names must be unique after UTF-8 conversion.' if result.key?(key)
              result[key] = json_value(child, seen, depth + 1)
            end
          end
        ensure
          seen.delete(value.object_id)
        end
      when String
        utf8_string(value)
      when Integer, TrueClass, FalseClass, NilClass
        value
      when Float
        raise ArgumentError, 'JSON numbers must be finite.' unless value.finite?
        value
      else
        raise ArgumentError, 'Request parameters must contain only JSON values.'
      end
    end

    def utf8_string(value)
      text = if value.encoding == Encoding::ASCII_8BIT
               value.dup.force_encoding(Encoding::UTF_8)
             else
               value.encode(Encoding::UTF_8)
             end
      raise ArgumentError, 'JSON strings must contain valid text convertible to UTF-8.' unless text.valid_encoding?
      text
    rescue EncodingError
      raise ArgumentError, 'JSON strings must contain valid text convertible to UTF-8.', cause: nil
    end

    def parse_json(body)
      text = body.dup.force_encoding(Encoding::UTF_8)
      raise JSON::ParserError, 'Invalid UTF-8.' unless text.valid_encoding?
      normalize_number(JSON.parse(text, max_nesting: 100, allow_nan: false, create_additions: false, decimal_class: JsonDecimal))
    end

    def parse_decimal(token)
      coefficient, exponent = token.split(/[eE]/, 2)
      if exponent
        digits = exponent.delete_prefix('-').delete_prefix('+').sub(/\A0+/, '')
        if digits.length > 4 || digits.to_i > MAX_DECIMAL_EXPONENT
          raise JSON::ParserError, 'JSON number exceeds the supported size.'
        end
      end
      value = BigDecimal(token)
      unless value.finite? && value.exponent.abs <= MAX_DECIMAL_EXPONENT && !(value.zero? && coefficient.match?(/[1-9]/))
        raise JSON::ParserError, 'JSON number cannot be represented without losing its value.'
      end
      value
    rescue ArgumentError
      raise JSON::ParserError, 'JSON number cannot be represented.', cause: nil
    end

    def normalize_number(value)
      case value
      when BigDecimal
        unless value.finite? && value.exponent.abs <= MAX_DECIMAL_EXPONENT
          raise JSON::ParserError, 'JSON number exceeds the supported size.'
        end
        value.frac.zero? ? value.to_i : value
      when Array
        value.map { |child| normalize_number(child) }
      when Hash
        value.transform_values { |child| normalize_number(child) }
      else
        value
      end
    end

    def plain(value)
      case value
      when ApiResource then value.to_h
      when Hash then value.transform_values { |child| plain(child) }
      when Array then value.map { |child| plain(child) }
      when String then value.dup
      else value
      end
    end
  end
end

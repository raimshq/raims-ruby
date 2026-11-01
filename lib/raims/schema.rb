# frozen_string_literal: true

module Raims
  module Schema
    CONTRACT = Util.deep_freeze(JSON.parse(File.read(File.join(__dir__, 'generated/contract.json'), encoding: 'UTF-8')))
    module_function

    def resolve(schema, response = nil)
      seen = {}
      while schema.key?('$ref')
        reference = schema.fetch('$ref')
        unless reference.is_a?(String) && reference.start_with?('#/components/schemas/') && !seen[reference] && seen.length < 100
          fail_response(response)
        end
        seen[reference] = true
        key = reference.delete_prefix('#/components/schemas/').gsub('~1', '/').gsub('~0', '~')
        target = CONTRACT.fetch('schemas')[key]
        fail_response(response) unless target.is_a?(Hash)
        schema = target.merge(schema.reject { |name, _value| name == '$ref' })
      end
      schema
    end

    def validate(value, schema, response = nil, depth = 0)
      fail_response(response) if depth > 100
      schema = resolve(schema, response)
      variants = schema['anyOf'] || schema['oneOf']
      if variants
        matched = variants.any? do |variant|
          begin
            validate(value, variant, response, depth + 1)
            true
          rescue UnexpectedResponseError
            false
          end
        end
        fail_response(response) unless matched
        return
      end
      schema.fetch('allOf', []).each { |part| validate(value, part, response, depth + 1) }
      kinds = Array(schema['type'])
      if value.nil?
        return if kinds.empty? || kinds.include?('null') || schema['nullable']
        fail_response(response)
      end
      kind = kinds.find { |candidate| candidate != 'null' }
      case kind
      when 'object', nil
        if kind == 'object' || schema.key?('properties')
          fail_response(response) unless value.is_a?(Hash) && schema.fetch('required', []).all? { |key| value.key?(key) }
          additional = schema['additionalProperties']
          value.each do |key, child|
            child_schema = schema.fetch('properties', {})[key] || (additional.is_a?(Hash) ? additional : {})
            validate(child, child_schema, response, depth + 1)
          end
        end
      when 'array'
        fail_response(response) unless value.is_a?(Array)
        value.each { |child| validate(child, schema.fetch('items', {}), response, depth + 1) }
      when 'integer' then fail_response(response) unless value.is_a?(Integer)
      when 'number' then fail_response(response) unless value.is_a?(Numeric) && value.finite?
      when 'boolean' then fail_response(response) unless value == true || value == false
      when 'string' then fail_response(response) unless value.is_a?(String)
      when 'null' then fail_response(response)
      end
    end

    def fail_response(response)
      raise UnexpectedResponseError.new('The API response does not match the published structure.', last_response: response)
    end

    def hydrate(value, schema = {}, response = nil, depth = 0)
      fail_response(response) if depth > 100
      model = schema.fetch('$ref', '').split('/').last
      resolved = resolve(schema, response)
      variants = resolved['anyOf'] || resolved['oneOf']
      if variants
        variants.each do |variant|
          begin
            validate(value, variant, response, depth + 1)
            return hydrate(value, variant, response, depth + 1)
          rescue UnexpectedResponseError
            next
          end
        end
      end
      case value
      when Hash
        props = resolved.fetch('properties', {})
        additional = resolved['additionalProperties']
        data = value.transform_keys(&:dup).each_with_object({}) do |(key, child), result|
          result[key] = hydrate(child, props[key] || (additional.is_a?(Hash) ? additional : {}), nil, depth + 1)
        end
        klass = model && Raims.const_defined?(model, false) ? Raims.const_get(model, false) : ApiResource
        klass = ApiResource unless klass.is_a?(Class) && klass <= ApiResource
        klass.new(data, last_response: response)
      when Array
        value.map { |child| hydrate(child, resolved.fetch('items', {}), nil, depth + 1) }.freeze
      when String then value.freeze
      else value
      end
    end
  end
end

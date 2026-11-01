# frozen_string_literal: true

module Raims
  class ApiResource
    attr_reader :last_response

    def initialize(data = {}, last_response: nil)
      @data = Util.deep_freeze(data.dup)
      @last_response = last_response
      freeze
    end

    def [](key)
      @data[key.to_s]
    end

    def key?(key)
      @data.key?(key.to_s)
    end

    def to_h
      @data.transform_values { |value| Util.plain(value) }
    end
    alias to_hash to_h

    def inspect
      "#<#{self.class}>"
    end
    alias to_s inspect
  end
end

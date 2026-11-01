# frozen_string_literal: true

require 'set'

module Raims
  class ApiList < ApiResource
    include Enumerable

    def initialize(resource, client:, operation_id:, path_params:, params:, options:)
      @client, @operation_id, @options = client, operation_id, options
      @path_params = Util.deep_freeze(Util.json_value(path_params))
      @params = Util.deep_freeze(Util.json_value(params))
      super(resource.instance_variable_get(:@data), last_response: resource.last_response)
    end

    def list
      self['list']
    end

    def page
      self['page']
    end

    def each(&block)
      return enum_for(:each) unless block
      list.each(&block)
    end

    def next_page
      load_page(true)
    end

    def to_h
      ApiResource.instance_method(:to_h).bind_call(self)
    end
    alias to_hash to_h

    def previous_page
      load_page(false)
    end

    def auto_paging_each
      return enum_for(:auto_paging_each) unless block_given?
      current = self
      seen = Set.new
      seen.add(@params['after']) if @params['after']
      loop do
        current.each { |item| yield item }
        params = current.send(:navigation, true)
        return self unless params
        cursor = params.fetch('after')
        if seen.include?(cursor)
          raise UnexpectedResponseError.new('Pagination returned a repeated cursor.', last_response: current.last_response)
        end
        following = current.next_page
        seen.add(cursor)
        current = following
      end
    end

    def auto_paging_to_a(limit)
      raise ArgumentError, 'limit must be a non-negative integer.' unless limit.is_a?(Integer) && limit >= 0
      return [] if limit.zero?
      result = []
      auto_paging_each do |item|
        result << item
        break if result.length >= limit
      end
      result
    end

    def inspect
      "#<#{self.class} items=#{list.length}>"
    end
    alias to_s inspect

    private

    def navigation(forward)
      flag, cursor_key, key, opposite = forward ? %w[has_next next_after after before] : %w[has_previous previous_before before after]
      return nil unless page[flag]
      cursor = page[cursor_key]
      unless cursor.is_a?(String) && !cursor.empty? && cursor != @params[key]
        raise UnexpectedResponseError.new('Pagination returned a missing or repeated cursor.', last_response: last_response)
      end
      result = @params.dup
      result.delete(opposite)
      result[key] = cursor
      result
    end

    def load_page(forward)
      params = navigation(forward)
      return nil unless params
      @client.request(@operation_id, path_params: @path_params, params: params, options: @options)
    end
  end
end

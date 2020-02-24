# frozen_string_literal: true

require 'sqb/base'
require 'sqb/filtering'
require 'sqb/limiting'

module SQB
  class Update < Base
    include SQB::Filtering
    include SQB::Limiting

    def to_sql
      [].tap do |query|
        query << 'UPDATE'
        query << escape_and_join(@options[:database_name], @table_name)
        query << 'SET'
        if @sets && !@sets.empty?
          query << @sets.map do |key, value|
            "#{escape_and_join(@table_name, key)} = #{value}"
          end.join(', ')
        else
          raise NoValuesError, 'No values have been updated. Use `set` to set the values to update.'
        end

        if @where && !@where.empty?
          query << 'WHERE'
          query << @where.join(' AND ')
        end

        query << "LIMIT #{@limit.to_i}" if @limit

        query << "OFFSET #{@offset.to_i}" if @offset
      end.join(' ')
    end

    # Set a value to be updated
    #
    # @param key [String]
    # @param value [String, nil]
    def set(hash)
      if @where
        raise QueryError, 'Filtering has already been provided. Must filter after setting values.'
      end

      @sets ||= {}
      hash.each do |key, value|
        @sets[key] = value_escape(value)
      end
      self
    end
  end
end

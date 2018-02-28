require 'sqb/base'
require 'sqb/filtering'
require 'sqb/limiting'

module SQB
  class Update < Base

    include SQB::Filtering
    include SQB::Limiting

    def to_sql
      [].tap do |query|
        query << "UPDATE"
        query << escape_and_join(@options[:database_name], @table_name)
        query << "SET"
        if @sets && !@sets.empty?
          query << @sets.map do |key, value|
            "#{escape_and_join(@table_name, key)} = #{value_escape(value)}"
          end.join(', ')
        else
          raise NoUpdatesError, "No variables have been updated"
        end

        if @where && !@where.empty?
          query << "WHERE"
          query << @where.join(' AND ')
        end

        if @limit
          query << "LIMIT #{@limit.to_i}"
        end

        if @offset
          query << "OFFSET #{@offset.to_i}"
        end
      end.join(' ')
    end

    # Set a value to be updated
    #
    # @param key [String]
    # @param value [String, nil]
    def set(hash)
      @sets ||= {}
      hash.each do |key, value|
        @sets[key] = value
      end
      self
    end

  end
end

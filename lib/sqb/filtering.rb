require 'sqb/where_dsl'

module SQB
  module Filtering

    # Add a condition to the query by providing a hash of keys and values.
    #
    # @param hash [Hash]
    # @return [Query]
    def where(hash = nil, &block)
      if hash
        if @where_within_or && @where_within_or.last
          @where_within_or.last << hash
        else
          @where ||= []
          @where << hash_to_sql(hash)
        end
      elsif block_given?
        dsl = WhereDSL.new
        block.call(dsl)
        where(dsl.hash)
      else
        raise QueryError, "Must provide a hash or a block to `where`"
      end
      self
    end

    # Set that all conditions added in this block should be joined using OR
    # rather than AND.
    def or(&block)
      if @where_within_or.is_a?(Array)
        raise QueryError, "Cannot nest an or block within another or block"
      end

      @where_within_or ||= []
      # Start by making an array within the OR block for this calling
      @where_within_or << []
      # Execute the block. All queries to 'where' will be added to the last
      # array in the chain (created above)
      block.call
    ensure
      # Start work on a full array of SQL fragments for all OR queries
      @where_within_or_sql ||= []
      # After each OR call, store up the SQL fragment for all where queries
      # executed within the block.
      if w = @where_within_or.pop
        @where_within_or_sql << w.map do |w|
          hash_to_sql(w)
        end.join(' OR ')
      end

      # When there are no fragments in the chain left, add it to the main
      # where chain for the query.
      if @where_within_or.empty?
        @where ||= []
        @where << "(#{@where_within_or_sql.flatten.join(' OR ')})"
        @where_within_or_sql = nil
      end
      self
    end

    private

    def hash_to_sql(hash, joiner = ' AND ')
      sql = hash.map do |key, value|
        with_table_and_column(key) do |table, column|
          key = escape_and_join(table, column)
          if value.is_a?(Array)
            condition(key, :in, value)
          elsif value.is_a?(Hash)
            sql = value.map do |operator, value|
              condition(key, operator, value)
            end
            sql.empty? ? "1=0" : sql.join(joiner)
          else
            condition(key, :equal, value)
          end
        end
      end.join(joiner)
      "(#{sql})"
    end

    def condition(key, operator, value)
      case operator
      when :equal
        if value.nil?
          "#{key} IS NULL"
        else
          "#{key} = #{value_escape(value)}"
        end
      when :not_equal
        if value.nil?
          "#{key} IS NOT NULL"
        else
          "#{key} != #{value_escape(value)}"
        end
      when :less_than, :lt
        "#{key} < #{value_escape(value)}"
      when :greater_than, :gt
        "#{key} > #{value_escape(value)}"
      when :less_than_or_equal_to, :lte
        "#{key} <= #{value_escape(value)}"
      when :greater_than_or_equal_to, :gte
        "#{key} >= #{value_escape(value)}"
      when :in, :not_in
        escaped_values = value.map { |v| value_escape(v) }.join(', ')
        if escaped_values.empty?
          # If there are no values to search from, don't find anything
          "1=0"
        else
          op = operator == :in ? "IN" : "NOT IN"
          "#{key} #{op} (#{escaped_values})"
        end
      when :like
        "#{key} LIKE #{value_escape(value)}"
      when :not_like
        "#{key} NOT LIKE #{value_escape(value)}"
      else
        raise InvalidOperatorError, "Invalid operator '#{operator}'"
      end
    end

  end
end

module SQB
  module Filtering

    # Add a condition to the query by providing a hash of keys and values.
    #
    # @param hash [Hash]
    # @return [Query]
    def where(hash)
      if @where_within_or && @where_within_or.last
        @where_within_or.last << hash
      else
        @where ||= []
        @where << hash_to_sql(hash, @table_name)
      end
      self
    end

    # Set that all conditions added in this block should be joined using OR
    # rather than AND.
    def or(&block)
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
          hash_to_sql(w, @table_name)
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

    def hash_to_sql(hash, table, joiner = ' AND ')
      sql = hash.map do |key, value|
        if key.is_a?(Hash)
          table = key.first[0]
          key = key.first[1]
        end

        key = escape_and_join(table, key)

        if value.is_a?(Array)
          escaped_values = value.map { |v| value_escape(v) }.join(', ')
          "#{key} IN (#{escaped_values})"
        elsif value.is_a?(Hash)
          sql = []
          value.each do |operator, value|
            case operator
            when :not_equal
              if value.nil?
                sql << "#{key} IS NOT NULL"
              else
                sql << "#{key} != #{value_escape(value)}"
              end
            when :equal
              if value.nil?
                sql << "#{key} IS NULL"
              else
                sql << "#{key} = #{value_escape(value)}"
              end
            when :less_than
              sql << "#{key} < #{value_escape(value)}"
            when :greater_than
              sql << "#{key} > #{value_escape(value)}"
            when :less_than_or_equal_to
              sql << "#{key} <= #{value_escape(value)}"
            when :greater_than_or_equal_to
              sql << "#{key} >= #{value_escape(value)}"
            when :in, :not_in
              escaped_values = value.map { |v| value_escape(v) }.join(', ')
              op = operator == :in ? "IN" : "NOT IN"
              sql << "#{key} #{op} (#{escaped_values})"
            when :like
              sql << "#{key} LIKE #{value_escape(value)}"
            when :not_like
              sql << "#{key} NOT LIKE #{value_escape(value)}"
            else
              raise InvalidOperatorError, "Invalid operator '#{operator}'"
            end
          end
          sql.empty? ? "1=0" : sql.join(joiner)
        elsif value == nil
          "#{key} IS NULL"
        else
          "#{key} = #{value_escape(value)}"
        end
      end.join(joiner)
      "(#{sql})"
    end

  end
end

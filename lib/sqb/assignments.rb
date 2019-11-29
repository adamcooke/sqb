module SQB
  module Assignments

    private

    def hash_to_sql(hash, joiner = ' AND ')
      sql = hash.map do |key, value|
        with_table_and_column(key) do |table, column|
          if key.is_a?(SQB::Select)
            key.prepared_arguments.each do |value|
              @prepared_arguments << value
            end
            key = "(#{key.to_sql})"
          else
            key = escape_and_join(table, column)
          end

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

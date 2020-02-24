module SQB
  module Escaping

    private

    def escape(name)
      if name.is_a?(SafeString)
        name
      elsif name == SQB::STAR
        "*"
      else
        "`#{name.to_s.gsub('`', '``')}`"
      end
    end

    def escape_function(name)
      if name.is_a?(SafeString)
        name
      else
        name.to_s.gsub(/[^a-z0-9\_]/i, '').upcase
      end
    end

    def value_escape(value)
      if value == true
        1
      elsif value == false
        0
      elsif value.nil?
        'NULL'
      elsif value.is_a?(Integer)
        value.to_i
      elsif value.is_a?(SQB::SafeString)
        value.to_s
      else
        if @options && @options[:escaper]
          @options[:escaper].call(value.to_s)
        else
          @prepared_arguments << value.to_s
          '?'
        end
      end
    end

    def with_table_and_column(input, &block)
      if input.is_a?(Hash)
        if input.size == 1
          block.call(input.first[0], input.first[1])
        else
          raise QueryError, "Column names provided as a hash must only contain a single item"
        end
      else
        if @table_name.is_a?(SQB::Select)
          block.call('subQuery', input)
        else
          block.call(@table_name, input)
        end
      end
    end

    def escape_and_join(*parts)
      if parts.last.is_a?(SafeString)
        # If a safe string is provided as a column name, we'll
        # always use this even if a table name is provided too.
        parts.last
      elsif parts.last.is_a?(SQB::Select)
        parts.last.prepared_arguments.each do |arg|
          @prepared_arguments << arg
        end
        "(#{parts.last.to_sql})"
      else
        parts.compact.map { |part| escape(part) }.join('.')
      end
    end

  end
end

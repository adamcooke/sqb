require 'sqb/base'

module SQB
  class Insert < Base

    def to_sql
      [].tap do |query|
        query << "#{mysql_verb} INTO"
        query << escape_and_join(@options[:database_name], @table_name)
        if @values.nil? || @values.empty?
          raise NoValuesError, "No values have been specified. Use `value` to add values to the query."
        end
        query << "(#{columns.join(', ')})"
        query << "VALUES"
        query << "(#{values.join(', ')})"
      end.join(' ')
    end

    # Set a value to be inserted
    #
    # @param key [String]
    # @param value [String, nil]
    def value(hash)
      @values ||= {}
      hash.each do |key, value|
        @values[key] = value
      end
      self
    end
    alias_method :values, :value

    private

    def columns
      @values.keys.map { |k| escape(k) }
    end

    def values
      @values.values.map { |v| value_escape(v) }
    end

    def mysql_verb
      "INSERT"
    end

  end
end

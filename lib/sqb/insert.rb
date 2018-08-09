require 'sqb/base'

module SQB
  class Insert < Base

    def to_sql
      [].tap do |query|
        values_sql = values.map { |rec| "(" + rec.join(', ') + ")" }.join(', ')
        query << "#{mysql_verb} INTO"
        query << escape_and_join(@options[:database_name], @table_name)
        if values_sql.empty?
          raise NoValuesError, "No values have been specified. Use `value` to add values to the query."
        end
        query << "(#{columns.join(', ')})"
        query << "VALUES"
        query << values_sql
      end.join(' ')
    end

    # Set a value to be inserted
    #
    # @param key [String]
    # @param value [String, nil]
    def value(hash)
      if @record.nil?
        record = (@local_record ||= {})
      else
        record = @record
      end

      hash.each do |key, value|
        record[key] = value
      end

      self
    end
    alias_method :values, :value

    def record(&block)
      @record = {}
      block.call
      @records ||= []
      @records << @record
      @record = nil
    end

    private

    def columns
      columns_keys.map { |c| escape(c) }
    end

    def columns_keys
      all_records.map(&:keys).flatten.uniq
    end

    def values
      all_records.map do |record|
        columns_keys.map do |col|
          value_escape(record[col])
        end
      end
    end

    def all_records
      [@local_record, *@records || []].compact
    end

    def mysql_verb
      "INSERT"
    end

  end
end

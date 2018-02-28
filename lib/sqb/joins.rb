module SQB
  module Joins

    # Add a join
    #
    # @param table_name [String, Symbol]
    # @param foreign_key [String, Symbol]
    # @option options [Hash] :where
    # @option options [Array] :select
    # @return [Query]
    def join(table_name, foreign_key, options = {})
      @joins ||= []
      @joins_name_mapping ||= {}

      if options[:name]
        join_name = options[:name]
      else
        @joins_name_mapping[table_name] ||= 0
        join_name= "#{table_name}_#{@joins_name_mapping[table_name]}"
        @joins_name_mapping[table_name] += 1
      end

      @joins << [].tap do |query|
        query << "INNER JOIN"
        query << escape_and_join(@options[:database_name], table_name)
        query << "AS"
        query << escape(join_name)
        query << "ON"
        query << escape_and_join(@table_name, 'id')
        query << "="
        query << escape_and_join(join_name, foreign_key)
      end.join(' ')

      if options[:where]
        join_where = options[:where].each_with_object({}) do |(column, value), hash|
          hash[{join_name => column}] = value
        end
        where(join_where)
      end

      if columns = options[:columns]
        for field in columns
          column({join_name => field}, :as => "#{join_name}_#{field}")
        end
      end

      if g = options[:group_by]
        group_by(join_name => g.is_a?(Symbol) ? g : :id)
      end

      self
    end

  end
end

# frozen_string_literal: true

module SQB
  module Joins
    TYPES_OF_JOIN = %i[inner left right].freeze

    # Add a join
    #
    # @param table_name [String, Symbol]
    # @param foreign_key [String, Symbol, Array]
    # @option options [Hash] :where
    # @option options [Array] :select
    # @return [Query]
    def join(table_name, foreign_key, options = {})
      if foreign_key.is_a?(Array)
        local_key = if foreign_key[1].is_a?(Hash)
                      foreign_key[1]
                    else
                      { @table_name => foreign_key[1] }
                    end
        foreign_key = foreign_key[0]
      else
        local_key = { @table_name => 'id' }
        foreign_key = foreign_key.to_s
      end

      type = options[:type] || :inner

      unless TYPES_OF_JOIN.include?(type)
        raise QueryError, "Invalid join type: #{type}"
      end

      @joins ||= []
      @joins_name_mapping ||= {}
      @join_names ||= []

      if options[:name]
        join_name = options[:name]
      else
        @joins_name_mapping[table_name] ||= 0
        join_name = "#{table_name}_#{@joins_name_mapping[table_name]}"
        @joins_name_mapping[table_name] += 1
      end

      @join_names << join_name.to_sym

      @joins << [].tap do |query|
        query << if type == :inner
                   'INNER'
                 else
                   "#{type.to_s.upcase} OUTER"
                 end
        query << 'JOIN'
        query << escape_and_join(@options[:database_name], table_name)
        query << 'AS'
        query << escape(join_name)
        query << 'ON'

        join_where = {}
        join_where[local_key] = SQB.safe(escape_and_join(join_name, foreign_key))
        if options[:conditions]
          options[:conditions].each do |(column, value)|
            join_where[{ join_name => column }] = value
          end
        end

        query << hash_to_sql(join_where)
      end.join(' ')

      if options[:where]
        join_where = options[:where].each_with_object({}) do |(column, value), hash|
          hash[{ join_name => column }] = value
        end
        where(join_where)
      end

      if columns = options[:columns]
        columns.each do |field|
          column({ join_name => field }, as: "#{join_name}_#{field}")
        end
      end

      if g = options[:group_by]
        group_by(join_name => g.is_a?(Symbol) ? g : :id)
      end

      self
    end

    def has_join?(name)
      return false unless @join_names.is_a?(Array)

      @join_names.include?(name.to_sym)
    end
  end
end

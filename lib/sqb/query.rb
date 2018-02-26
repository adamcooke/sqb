require 'sqb/error'

module SQB
  class Query

    VALID_ORDERS = ['ASC', 'DESC']

    def initialize(table_name, &escape_block)
      @table_name = table_name
      @columns = []
      @joins = []
      @joins_name_mapping = {}
      @where = []
      @orders = []
      @groups = []
      @limit = nil
      @offset = nil
      @distinct = false
      @where_within_or = []
      @escape_block = escape_block
    end

    # Generate the full SQL query for this query.
    #
    # @return [String]
    def to_sql
      [].tap do |query|
        query << "SELECT"
        query << "DISTINCT" if @distinct
        if @columns.empty?
          query << column_tuple(@table_name, '*')
        else
          query << @columns.join(', ')
        end
        query << "FROM"
        query << escape(@table_name)

        unless @joins.empty?
          query << @joins.join(' ')
        end

        unless @where.empty?
          query << "WHERE"
          query << @where.join(' AND ')
        end

        unless @groups.empty?
          query << "GROUP BY"
          query << @groups.join(', ')
        end

        unless @orders.empty?
          query << "ORDER BY"
          query << @orders.join(', ')
        end

        if @limit
          query << "LIMIT #{@limit.to_i}"
        end

        if @offset
          query << "OFFSET #{@offset.to_i}"
        end
      end.join(' ')
    end

    # Add a column to the query
    #
    # @param column [String, Symbol, Hash] the column name (or a hash with table & column name)
    # @option options [String] :function a function to wrap around the column
    # @options options [String] :as the name to return this column as
    # @return [Query] returns the query
    def column(column, options = {})
      with_table_and_column(column) do |table, column|
        @columns << [].tap do |query|
          if options[:method]
            query << "#{options[:method]}("
          end
          query << column_tuple(table, column)
          if options[:method]
            query << ")"
          end
          if options[:as]
            query << "AS"
            query << escape(options[:as])
          end
        end.join(' ')
      end
      self
    end

    # Replace all existing columns with the given column
    def column!(*args)
      @columns = []
      column(*args)
    end

    # Add a condition to the query by providing a hash of keys and values.
    #
    # @param hash [Hash]
    # @return [Query]
    def where(hash)
      if @where_within_or.last
        @where_within_or.last << hash
      else
        @where << hash_to_sql(hash, @table_name)
      end
      self
    end

    # Set that all conditions added in this block should be joined using OR
    # rather than AND.
    def or(&block)
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
        @where << "(#{@where_within_or_sql.flatten.join(' OR ')})"
        @where_within_or_sql = nil
      end
    end

    # Limit the number of records return
    #
    # @param number [Integer]
    # @return [Query]
    def limit(number)
      @limit = number&.to_i
      self
    end

    # Set the offset
    #
    # @param number [Integer]
    # @return [Query]
    def offset(number)
      @offset = number&.to_i
      self
    end

    # Add an order column
    #
    # @param column [String, Symbol, Hash]
    # @param direction [String] 'ASC' or 'DESC' (default 'ASC')
    # @return [Query]
    def order(column, direction = nil)
      direction = direction ? direction.to_s.upcase : 'ASC'

      unless VALID_ORDERS.include?(direction)
        raise Error, "Invalid order direction #{direction}"
      end

      with_table_and_column(column) do |table, column|
        @orders << [column_tuple(table, column), direction].join(' ')
      end

      self
    end

    # Add an order replacing all previous ones
    def order!(*args)
      @orders = []
      order(*args)
    end

    # Remove all ordering for this query
    def no_order!
      @orders = []
    end

    # Add a grouping
    #
    # @param column [String, Symbol, Hash]
    # @return [Query]
    def group_by(column)
      with_table_and_column(column) do |table, column|
        @groups << column_tuple(table, column)
      end
      self
    end

    # Add a join
    #
    # @param table_name [String, Symbol]
    # @param foreign_key [String, Symbol]
    # @option options [Hash] :where
    # @option options [Array] :select
    # @return [Query]
    def join(table_name, foreign_key, options = {})

      if options[:name]
        join_name = options[:name]
      else
        @joins_name_mapping[table_name] ||= 0
        join_name= "#{table_name}_#{@joins_name_mapping[table_name]}"
        @joins_name_mapping[table_name] += 1
      end

      @joins << [].tap do |query|
        query << "INNER JOIN"
        query << escape(table_name)
        query << "AS"
        query << escape(join_name)
        query << "ON"
        query << column_tuple(@table_name, 'id')
        query << "="
        query << column_tuple(join_name, foreign_key)
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

    def distinct
      @distinct = true
      self
    end

    private

    def hash_to_sql(hash, table, joiner = ' AND ')
      sql = hash.map do |key, value|
        if key.is_a?(Hash)
          table = key.first[0]
          key = key.first[1]
        end

        key = column_tuple(table, key)

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
            else
              raise Error, "Invalid operator '#{operator}'"
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

    def escape(name)
      "`#{name.to_s.gsub('`', '``')}`"
    end

    def value_escape(value)
      if value == true
        '1'
      elsif value == false
        '0'
      elsif value.nil?
        'NULL'
      elsif value.is_a?(Integer)
        value.to_i
      else
        if value.to_s.length == 0
          'NULL'
        else
          escaped_value = @escape_block ? @escape_block.call(value.to_s) : value.to_s
          "'" + escaped_value + "'"
        end
      end
    end

    def with_table_and_column(input, &block)
      if input.is_a?(Hash)
        input.each { |table, column| block.call(table, column) }
      else
        block.call(@table_name, input.to_sym)
      end
    end

    def column_tuple(table, column)
      [escape(table), escape(column)].join('.')
    end

  end
end

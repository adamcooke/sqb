require 'sqb/error'
require 'sqb/escaping'
require 'sqb/columns'
require 'sqb/filtering'
require 'sqb/joins'
require 'sqb/ordering'
require 'sqb/grouping'
require 'sqb/limiting'

module SQB
  class Query

    include SQB::Escaping
    include SQB::Columns
    include SQB::Filtering
    include SQB::Joins
    include SQB::Ordering
    include SQB::Grouping
    include SQB::Limiting

    attr_reader :prepared_arguments

    def initialize(table_name, options = {})
      @table_name = table_name
      @options = options
      @prepared_arguments = []
    end

    # Generate the full SQL query for this query.
    #
    # @return [String]
    def to_sql
      [].tap do |query|
        query << "SELECT"
        query << "DISTINCT" if @distinct
        if @columns.nil? || @columns.empty?
          query << escape_and_join(@table_name, '*')
        else
          query << @columns.join(', ')
        end

        query << "FROM"
        query << escape_and_join(@options[:database_name], @table_name)

        if @joins && !@joins.empty?
          query << @joins.join(' ')
        end

        if @where && !@where.empty?
          query << "WHERE"
          query << @where.join(' AND ')
        end

        if @groups && !@groups.empty?
          query << "GROUP BY"
          query << @groups.join(', ')
        end

        if @orders && !@orders.empty?
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

  end
end

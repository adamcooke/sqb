require 'sqb/base'
require 'sqb/columns'
require 'sqb/filtering'
require 'sqb/joins'
require 'sqb/ordering'
require 'sqb/grouping'
require 'sqb/limiting'

module SQB
  class Select < Base

    include SQB::Columns
    include SQB::Filtering
    include SQB::Joins
    include SQB::Ordering
    include SQB::Grouping
    include SQB::Limiting

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

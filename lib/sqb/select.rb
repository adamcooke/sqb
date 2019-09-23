require 'sqb/base'
require 'sqb/distinct'
require 'sqb/columns'
require 'sqb/filtering'
require 'sqb/joins'
require 'sqb/ordering'
require 'sqb/grouping'
require 'sqb/limiting'
require 'sqb/offsetting'
require 'sqb/index_hint'

module SQB
  class Select < Base

    include SQB::Distinct
    include SQB::Columns
    include SQB::Filtering
    include SQB::Joins
    include SQB::Ordering
    include SQB::Grouping
    include SQB::Limiting
    include SQB::Offsetting
    include SQB::IndexHint

    def to_sql
      [].tap do |query|
        query << "SELECT"
        query << "DISTINCT" if @distinct
        if @columns.nil? || @columns.empty?
          query << escape_and_join(@table_name, SQB::STAR)
        else
          query << @columns.join(', ')
        end

        query << "FROM"
        query << escape_and_join(@options[:database_name], @table_name)

        if @index_hint
          query << @index_hint
        end

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

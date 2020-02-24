# frozen_string_literal: true

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
        query << 'SELECT'
        query << 'DISTINCT' if @distinct
        query << if @columns.nil? || @columns.empty?
                   if @table_name.is_a?(SQB::Select)
                     escape_and_join('subQuery', SQB::STAR)
                   else
                     escape_and_join(@table_name, SQB::STAR)
                            end
                 else
                   @columns.join(', ')
                 end

        query << 'FROM'
        query << escape_and_join(@options[:database_name], @table_name)
        query << 'AS subQuery' if @table_name.is_a?(SQB::Select)

        if @index_hints && !@index_hints.empty?
          query << 'USE INDEX (' + @index_hints.join(', ') + ')'
        end

        query << @joins.join(' ') if @joins && !@joins.empty?

        if @where && !@where.empty?
          query << 'WHERE'
          query << @where.join(' AND ')
        end

        if @groups && !@groups.empty?
          query << 'GROUP BY'
          query << @groups.join(', ')
        end

        if @orders && !@orders.empty?
          query << 'ORDER BY'
          query << @orders.join(', ')
        end

        query << "LIMIT #{@limit.to_i}" if @limit

        query << "OFFSET #{@offset.to_i}" if @offset
      end.join(' ')
    end
  end
end

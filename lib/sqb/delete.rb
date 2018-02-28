require 'sqb/base'
require 'sqb/filtering'
require 'sqb/ordering'
require 'sqb/limiting'

module SQB
  class Delete < Base

    include SQB::Filtering
    include SQB::Ordering
    include SQB::Limiting

    def to_sql
      [].tap do |query|
        query << "DELETE FROM"
        query << escape_and_join(@options[:database_name], @table_name)

        if @where && !@where.empty?
          query << "WHERE"
          query << @where.join(' AND ')
        end

        if @orders && !@orders.empty?
          query << "ORDER BY"
          query << @orders.join(', ')
        end

        if @limit
          query << "LIMIT #{@limit.to_i}"
        end
      end.join(' ')
    end

  end
end

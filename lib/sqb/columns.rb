# frozen_string_literal: true

module SQB
  module Columns
    # Add a column to the query
    #
    # @param column [String, Symbol, Hash] the column name (or a hash with table & column name)
    # @option options [String] :function a function to wrap around the column
    # @options options [String] :as the name to return this column as
    # @return [Query] returns the query
    def column(column, options = {})
      @columns ||= []
      with_table_and_column(column) do |table, column|
        @columns << [].tap do |query|
          if options[:function].is_a?(SQB::SafeString) && options[:function] =~ /\A(\w+)\((.*)\)\z/i
            query << options[:function].gsub('$$', escape_and_join(table, column))
          elsif options[:function]
            query << "#{escape_function(options[:function])}("
            query << escape_and_join(table, column)
            query << ')'
          else
            query << escape_and_join(table, column)
          end

          if options[:as]
            query << ' AS '
            query << escape(options[:as])
          end
        end.join
      end
      self
    end

    # Replace all existing columns with the given column
    def column!(*args)
      @columns = []
      column(*args)
    end
  end
end

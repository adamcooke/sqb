# frozen_string_literal: true

module SQB
  module Grouping
    # Add a grouping
    #
    # @param column [String, Symbol, Hash]
    # @return [Query]
    def group_by(column)
      @groups ||= []
      with_table_and_column(column) do |table, column|
        @groups << escape_and_join(table, column)
      end
      self
    end
  end
end

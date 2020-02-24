# frozen_string_literal: true

module SQB
  module Ordering
    VALID_ORDERS = %w[ASC DESC].freeze

    # Add an order column
    #
    # @param column [String, Symbol, Hash]
    # @param direction [String] 'ASC' or 'DESC' (default 'ASC')
    # @return [Query]
    def order(column, direction = nil)
      direction = direction ? direction.to_s.upcase : 'ASC'

      unless VALID_ORDERS.include?(direction)
        raise InvalidOrderDirectionError, "Invalid order direction #{direction}"
      end

      @orders ||= []

      with_table_and_column(column) do |table, column|
        @orders << [escape_and_join(table, column), direction].join(' ')
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
  end
end

require 'sqb/error'
require 'sqb/escaping'

module SQB
  class Base

    include SQB::Escaping

    attr_reader :prepared_arguments
    attr_reader :options

    def initialize(table_name, options = {}, &block)
      @table_name = table_name
      @options = options
      @prepared_arguments = []
      block.call(self) if block_given?
    end

    # Generate the full SQL query for this query.
    #
    # @return [String]
    def to_sql
    end

  end
end

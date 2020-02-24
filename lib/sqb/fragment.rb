# frozen_string_literal: true

require 'sqb/assignments'
require 'sqb/escaping'

module SQB
  class Fragment
    include Escaping
    include Assignments

    def initialize(table_name, joiner)
      @joiner = joiner
      @table_name = table_name
      @prepared_arguments = []
      @items = []
    end

    attr_reader :prepared_arguments
    attr_reader :joiner

    def empty?
      @items.empty?
    end

    def add_item(item)
      @items << item
    end

    def to_sql
      sql = @items.map do |item|
        hash_to_sql(item, @joiner)
      end.join(" #{@joiner} ")
      "(#{sql})"
    end
  end
end

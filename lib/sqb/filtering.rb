require 'sqb/where_dsl'
require 'sqb/assignments'

module SQB
  module Filtering

    include Assignments

    # Add a condition to the query by providing a hash of keys and values.
    #
    # @param hash [Hash]
    # @return [Query]
    def where(hash = nil, &block)
      if hash
        if @where_within_or && @where_within_or.last
          @where_within_or.last << hash
        else
          @where ||= []
          @where << hash_to_sql(hash)
        end
      elsif block_given?
        dsl = WhereDSL.new
        block.call(dsl)
        where(dsl.hash)
      else
        raise QueryError, "Must provide a hash or a block to `where`"
      end
      self
    end

    # Set that all conditions added in this block should be joined using OR
    # rather than AND.
    def or(&block)
      select_fragment('OR', &block)
    end

    # Set that all conditions added in this block should be joined using AND.
    # This is the default behaviour but this allows the where queries within to
    # be grouped together in the query too.
    def and(&block)
      select_fragment('AND', &block)
    end

    private

    def select_fragment(joiner, &block)
      if @where_within_or.is_a?(Array)
        @no_ensure = true
        raise QueryError, "Cannot nest an or block within another or block"
      end

      @where_within_or ||= []

      # Start by making an array within the OR block for this calling
      @where_within_or << []

      # Execute the block. All queries to 'where' will be added to the last
      # array in the chain (created above)
      block.call

    ensure
      return if @no_ensure

      # Start work on a full array of SQL fragments for all OR queries
      @where_within_or_sql ||= []

      # After each OR call, store up the SQL fragment for all where queries
      # executed within the block.
      if w = @where_within_or.pop
        @where_within_or_sql << w.map do |w|
          hash_to_sql(w)
        end.join(" #{joiner} ")
      end

      # When there are no fragments in the chain left, add it to the main
      # where chain for the query.
      if @where_within_or.empty?
        @where ||= []
        @where << "(#{@where_within_or_sql.flatten.join(" #{joiner} ")})"
        @where_within_or_sql = nil
        @where_within_or = nil
      end
      self
    end

  end
end

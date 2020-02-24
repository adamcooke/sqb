require 'sqb/where_dsl'
require 'sqb/assignments'
require 'sqb/fragment'

module SQB
  module Filtering

    include Assignments

    # Add a condition to the query by providing a hash of keys and values.
    #
    # @param hash [Hash]
    # @return [Query]
    def where(hash = nil, &block)
      if hash
        if @active_fragment
          @active_fragment.add_item(hash || block)
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
      # We're storing all fragments that are added
      @fragments ||= {}

      # Create a new fragment object
      current_fragment = Fragment.new(@table_name, joiner)

      # Store the fragment that was active when this fragment
      # was created (when this fragment ends this will revert
      # to being the active fragment)
      @fragments[current_fragment] = @active_fragment

      # Set the active fragment, this is the fragment that where queries
      # will be added to
      @active_fragment = current_fragment

      # Yield the block
      yield block
    ensure
      # Set the active fragment back to the fragment that existed
      # before this fragment was created.
      @active_fragment = @fragments[current_fragment]

      # When we're done with all fragments (i.e. the active fragment is
      # nil) we will add all queries into the root query.
      if @active_fragment.nil?
        all_fragments_where = []
        @fragments.keys.each do |fragment|
          next if fragment.empty?

          all_fragments_where << fragment.to_sql
          fragment.prepared_arguments.each do |arg|
            @prepared_arguments << arg
          end
        end

        unless all_fragments_where.empty?
          @where ||= []
          sql = all_fragments_where.join(" #{current_fragment.joiner} ")
          if all_fragments_where.size == 1
            @where << sql
          else
            @where << "(#{sql})"
          end
        end

        @fragments = nil
      end
    end

  end
end

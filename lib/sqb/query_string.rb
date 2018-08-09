module SQB
  class QueryString

    def initialize(&block)
      @query = []
      block.call(self) if block_given?
    end

    def to_s
      @query.join(" ")
    end

    def add(*items)
      if @group_joiner
        @group_items ||= []
        @group_items << items
      else
        items.flatten.each do |item|
          add_to_query(resolve_for_query(item))
        end
      end
    end

    def group(joiner, &block)
      @group_joiner = joiner
      block.call
    ensure
      if @group_items
        # If we have some group items after running our group,
        # add them into the query now.
        @group_items.each do |items|
          raw_q = items.map { |i| resolve_for_query(i) }.join(' ')
          raw_q << @group_joiner unless items === @group_items.last
          add_to_query(raw_q)
        end
      end
      @group_items = nil
      @group_joiner = nil
    end

    def with_brackets(&block)
      @open_bracket = true
      block.call
    ensure
      @query.last << ")"
      @open_bracket = nil
      @close_bracket = nil
    end

    private

    def add_to_query(item)
      item = "(" + item if @open_bracket
      @query << item.to_s
    ensure
      @open_bracket = nil
    end

    def resolve_for_query(item)
      item
    end

  end
end

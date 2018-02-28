module SQB
  module Limiting

    # Limit the number of records return
    #
    # @param number [Integer]
    # @return [Query]
    def limit(number)
      @limit = number&.to_i
      self
    end

    # Set the offset
    #
    # @param number [Integer]
    # @return [Query]
    def offset(number)
      @offset = number&.to_i
      self
    end

    def distinct
      @distinct = true
      self
    end

  end
end

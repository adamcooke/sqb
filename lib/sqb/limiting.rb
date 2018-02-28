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

  end
end

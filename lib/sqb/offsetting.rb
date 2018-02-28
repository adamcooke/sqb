module SQB
  module Offsetting

    # Set the offset
    #
    # @param number [Integer]
    # @return [Query]
    def offset(number)
      @offset = number&.to_i
      self
    end

  end
end

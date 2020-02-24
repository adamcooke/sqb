# frozen_string_literal: true

module SQB
  module Distinct
    def distinct
      @distinct = true
      self
    end
  end
end

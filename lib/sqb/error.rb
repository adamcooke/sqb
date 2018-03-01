module SQB
  class Error < StandardError
  end

  class EscapeBlockMissingError < Error
  end

  class InvalidOrderDirectionError < Error
  end

  class InvalidOperatorError < Error
  end

  class NoValuesError < Error
  end

  class QueryError < Error
  end
end

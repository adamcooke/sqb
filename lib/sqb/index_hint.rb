module SQB
  module IndexHint

    def index_hint(index)
      @index_hints ||= []
      @index_hints << escape(index)
      self
    end

    def no_index_hint!
      @index_hints = nil
      self
    end
    
  end
end

module SQB
  module IndexHint
    def index_hint(index)
      @index_hint = "USE INDEX (#{escape(index)})"
    end
  end
end

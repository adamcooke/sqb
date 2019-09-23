require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "index_hint" do

    it "it should allow an index hint to be added" do
      query.index_hint(:index_by_author)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` USE INDEX (`index_by_author`)'
    end
  end

end

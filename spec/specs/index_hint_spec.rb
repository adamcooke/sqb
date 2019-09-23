require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "index_hint" do

    it "should allow an index hint to be added" do
      query.index_hint(:index_by_author)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` USE INDEX (`index_by_author`)'
    end

    it "should be possible add two index hints" do
      query.index_hint(:index_by_author)
      query.index_hint(:index_by_date)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` USE INDEX (`index_by_author`, `index_by_date`)'
    end

    it "should be possible to clear index hints" do
      query.index_hint(:index_by_author)
      query.no_index_hint!
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts`'
    end

    it "should allow all methods to be chained" do
      query.index_hint(:index_by_date).no_index_hint!.index_hint(:index_by_author)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` USE INDEX (`index_by_author`)'
    end

  end

end

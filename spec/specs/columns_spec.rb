require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  context "columns" do

    it "should allow a column to be added" do
      query.column(:title)
      expect(query.to_sql).to eq 'SELECT `posts`.`title` FROM `posts`'
    end

    it "should allow multiple columns to be added" do
      query.column(:title)
      query.column(:content)
      expect(query.to_sql).to eq 'SELECT `posts`.`title`, `posts`.`content` FROM `posts`'
    end

    it "should allow distinct" do
      query.distinct
      expect(query.to_sql).to eq 'SELECT DISTINCT `posts`.`*` FROM `posts`'
    end

    context "escaping" do
      it "should escape column names" do
        query.column("title`here")
        expect(query.to_sql).to eq 'SELECT `posts`.`title``here` FROM `posts`'
      end

      it "should escape table names" do
        query.column("some`table" => :title)
        expect(query.to_sql).to eq 'SELECT `some``table`.`title` FROM `posts`'
      end
    end

  end

end

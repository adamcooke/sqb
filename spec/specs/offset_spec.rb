require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  context "offsets" do

    it "should allow a offset to be added" do
      query.offset(100)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` OFFSET 100'
    end

    it "should a offset to be removed" do
      query.offset(100)
      query.offset(nil)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
    end

    it "should always be an integer" do
      query.offset("Blah")
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` OFFSET 0'
    end

  end

end

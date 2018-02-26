require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  context "limits" do

    it "should allow a limit to be added" do
      query.limit(100)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` LIMIT 100'
    end

    it "should a limit to be removed" do
      query.limit(100)
      query.limit(nil)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
    end

    it "should always be an integer" do
      query.limit("Blah")
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` LIMIT 0'
    end

  end

end

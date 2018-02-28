require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

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

  context "distinct" do
    it "should appear before all columns" do
      query.distinct
      expect(query.to_sql).to eq 'SELECT DISTINCT `posts`.`*` FROM `posts`'
    end
  end


end

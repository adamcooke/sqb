require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

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

    it "should allow an alias" do
      query.column(:title, :as => :title2)
      expect(query.to_sql).to eq 'SELECT `posts`.`title` AS `title2` FROM `posts`'
    end

    it "should allow a function" do
      query.column(:id, :function => 'count', :as => 'count')
      expect(query.to_sql).to eq 'SELECT COUNT( `posts`.`id` ) AS `count` FROM `posts`'
    end

    it "should strip invalid characters from functions" do
      query.column(:id, :function => 'cou!--!nt')
      expect(query.to_sql).to eq 'SELECT COUNT( `posts`.`id` ) FROM `posts`'
    end

    it "should allow safe values to be passed in" do
      query.column(SQB.safe('BLAH(example)'))
      expect(query.to_sql).to eq "SELECT BLAH(example) FROM `posts`"
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

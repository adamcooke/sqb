require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "prepared statements" do
    it "should insert ? for each value" do
      query.where(:title => "Hello world!")
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` = ?)'
    end

    it "should provide the values in order" do
      query.where(:title => "Hello world!", :author => "Me")
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` = ? AND `posts`.`author` = ?)'
      expect(query.prepared_arguments[0]).to eq 'Hello world!'
      expect(query.prepared_arguments[1]).to eq 'Me'
    end

    it "should work for OR queries too" do
      query.where(:title => "Hello world!")
      query.or do
        query.where(:author => 'Dave')
        query.where(:author => 'Sarah')
      end
      expect(query.prepared_arguments[0]).to eq 'Hello world!'
      expect(query.prepared_arguments[1]).to eq 'Dave'
      expect(query.prepared_arguments[2]).to eq 'Sarah'
    end
  end

end

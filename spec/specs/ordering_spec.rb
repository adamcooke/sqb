require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  context "ordering" do

    it "should allow an order to be added with a default direction" do
      query.order(:title)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `posts`.`title` ASC'
    end

    it "should allow an order to be added with a specified direction in lower case" do
      query.order(:title, 'desc')
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `posts`.`title` DESC'
    end

    it "should allow an order to be added with a specified direction as a symbol" do
      query.order(:title, :desc)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `posts`.`title` DESC'
    end

    it "shold raise an error for invalid directions" do
      expect { query.order(:title, "potato") }.to raise_error(SQB::Error, /invalid order direction/i)
    end

    it "should allow multiple orders to be added" do
      query.order(:title)
      query.order(:posted_at, 'DESC')
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `posts`.`title` ASC, `posts`.`posted_at` DESC'
    end

    it "should allow the order chain to be reset" do
      query.order(:title)
      query.order!(:posted_at)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `posts`.`posted_at` ASC'
    end

    it "should allow order disabling" do
      query.order(:title)
      query.no_order!
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
    end

    context "escaping" do
      it "should escape column names" do
        query.order("column`name")
        expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `posts`.`column``name` ASC'
      end

      it "should escape table names" do
        query.order("table`name" => :title)
        expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` ORDER BY `table``name`.`title` ASC'
      end
    end

  end

end

require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  it "should start empty" do
    expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
  end

  it "should accept a block" do
    query = SQB::Select.new(:posts) do |q|
      q.column(:title)
    end
    expect(query.to_sql).to eq 'SELECT `posts`.`title` FROM `posts`'
  end

  it "should work with Query for backwards compatibility" do
    query = SQB::Query.new(:posts)
    expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
  end

end

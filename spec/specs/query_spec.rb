require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  it "should start empty" do
    expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
  end

  it "should raise an error if no escape block is given a query without prepared statements" do
    expect { SQB::Query.new(:posts, :prepared => false) }.to raise_error(SQB::EscapeBlockMissingError)
  end

end

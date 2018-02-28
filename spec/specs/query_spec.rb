require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  it "should start empty" do
    expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts`'
  end

end

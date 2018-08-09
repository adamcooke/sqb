require 'spec_helper'

describe SQB::Replace do

  subject(:query) { SQB::Replace.new(:posts) }

  it "should raise error if no data added" do
    expect { query.to_sql }.to raise_error(SQB::NoValuesError)
  end

  it "should add data to update" do
    query.value(:title => "Hello world!")
    expect(query.to_sql).to eq "REPLACE INTO `posts` (`title`) VALUES (?)"
  end

  it "should add multiple data items" do
    query.value(:title => "Hello world!", :author_id => 2)
    query.value(:description => "Something else")
    expect(query.to_sql).to eq "REPLACE INTO `posts` (`title`, `author_id`, `description`) VALUES (?, 2, ?)"
    expect(query.prepared_arguments[0]).to eq 'Hello world!'
    expect(query.prepared_arguments[1]).to eq 'Something else'
  end

  it "should handle nulls" do
    query.value(:title => nil)
    expect(query.to_sql).to eq "REPLACE INTO `posts` (`title`) VALUES (NULL)"
  end

end

require 'spec_helper'

describe SQB::Insert do

  subject(:query) { SQB::Insert.new(:posts) }

  it "should raise error if no data added" do
    expect { query.to_sql }.to raise_error(SQB::NoValuesError)
  end

  it "should add data to update" do
    query.value(:title => "Hello world!")
    expect(query.to_sql).to eq "INSERT INTO `posts` (`title`) VALUES (?)"
  end

  it "should add multiple data items" do
    query.value(:title => "Hello world!", :author_id => 2)
    query.value(:description => "Something else")
    expect(query.to_sql).to eq "INSERT INTO `posts` (`title`, `author_id`, `description`) VALUES (?, 2, ?)"
    expect(query.prepared_arguments[0]).to eq 'Hello world!'
    expect(query.prepared_arguments[1]).to eq 'Something else'
  end

  it "should handle nulls" do
    query.value(:title => nil)
    expect(query.to_sql).to eq "INSERT INTO `posts` (`title`) VALUES (NULL)"
  end

  it "should handle inserting multiple records" do
    query.record { query.value(:title => "Item 1") }
    query.record { query.value(:title => "Item 2", :type => "Widget") }
    query.record { query.value(:title => "Item 3") }
    expect(query.to_sql).to eq "INSERT INTO `posts` (`title`, `type`) VALUES (?, NULL), (?, ?), (?, NULL)"
  end

  it "should handle inserting multiple records" do
    query.record { query.value(:title => "Item 1") }
    query.record { query.value(:title => "Item 2", :type => "Widget") }
    query.record { query.value(:title => "Item 3") }
    query.value(:title => "Item 4")
    expect(query.to_sql).to eq "INSERT INTO `posts` (`title`, `type`) VALUES (?, NULL), (?, NULL), (?, ?), (?, NULL)"
    expect(query.prepared_arguments[0]).to eq "Item 4"
    expect(query.prepared_arguments[1]).to eq "Item 1"
    expect(query.prepared_arguments[2]).to eq "Item 2"
    expect(query.prepared_arguments[3]).to eq "Widget"
    expect(query.prepared_arguments[4]).to eq "Item 3"
  end


end

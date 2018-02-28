require 'spec_helper'

describe SQB::Update do

  subject(:query) { SQB::Update.new(:posts) }

  it "should raise error if no updates added" do
    expect { query.to_sql }.to raise_error(SQB::NoUpdatesError)
  end

  it "should add columns to update" do
    query.set(:title => "Hello world!")
    expect(query.to_sql).to eq "UPDATE `posts` SET `posts`.`title` = ?"
  end


  it "should add columns to update" do
    query.set(:title => "Hello world!", :author => 1)
    expect(query.to_sql).to eq "UPDATE `posts` SET `posts`.`title` = ?, `posts`.`author` = 1"
    expect(query.prepared_arguments[0]).to eq 'Hello world!'
  end

  it "should add where queries" do
    query.set(:title => "Hello world!")
    query.where(:id => 10)
    expect(query.to_sql).to eq "UPDATE `posts` SET `posts`.`title` = ? WHERE (`posts`.`id` = 10)"
  end

end

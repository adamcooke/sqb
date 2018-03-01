require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  it "should escape column names with backticks" do
    query.column("some`column`with`backticks")
    expect(query.to_sql).to eq "SELECT `posts`.`some``column``with``backticks` FROM `posts`"
  end

  it "should not escape safe strings as column names" do
    query.column(SQB.safe("random string"))
    expect(query.to_sql).to eq "SELECT random string FROM `posts`"
  end

  it "should not escape stars" do
    query.column(SQB::STAR)
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts`"
  end

  it "should escape function names" do
    query.column(:id, :function => "FUNC!WITHINVALID*CHARS")
    expect(query.to_sql).to eq "SELECT FUNCWITHINVALIDCHARS( `posts`.`id` ) FROM `posts`"
  end

  it "should not escape safe strings as function names" do
    query.column(:id, :function => SQB.safe("FUNC!SAFE"))
    expect(query.to_sql).to eq "SELECT FUNC!SAFE( `posts`.`id` ) FROM `posts`"
  end

  it "should escape true as 1" do
    query.where(:title => true)
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = 1)"
  end

  it "should escape false as 0" do
    query.where(:title => false)
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = 0)"
  end

  it "should escape nil as NULL" do
    query = SQB::Update.new(:posts)
    query.set(:title => nil)
    expect(query.to_sql).to eq "UPDATE `posts` SET `posts`.\`title` = NULL"
  end

  it "shouldn't escape integers" do
    query.where(:title => 1234)
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = 1234)"
  end

  it "should escape strings as ?" do
    query.where(:title => "Hello")
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = ?)"
  end

  it "should escape hashes as ?" do
    query.where(:title => {:equal => {:some => 'hash'}})
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = ?)"
    expect(query.prepared_arguments.first).to be_a(String)
  end

  it "should escape other objects as ?" do
    query.where(:title => Object.new)
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = ?)"
    expect(query.prepared_arguments.first).to be_a(String)
  end

  it "should not escape safe strings" do
    query.where(:title => SQB.safe('SOMETHING'))
    expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = SOMETHING)"
    expect(query.prepared_arguments).to be_empty
  end

end

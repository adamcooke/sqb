# frozen_string_literal: true

require 'spec_helper'

describe SQB::Select do
  subject(:query) { SQB::Select.new(:posts) }

  it 'should start empty' do
    expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts`'
  end

  it 'should accept a block' do
    query = SQB::Select.new(:posts) do |q|
      q.column(:title)
    end
    expect(query.to_sql).to eq 'SELECT `posts`.`title` FROM `posts`'
  end

  it 'should work with Query for backwards compatibility' do
    query = SQB::Select.new(:posts)
    expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts`'
  end

  it 'should be able to query another query' do
    query1 = SQB::Select.new(:posts)
    query2 = SQB::Select.new(query1)
    expect(query2.to_sql).to eq 'SELECT `subQuery`.* FROM (SELECT `posts`.* FROM `posts`) AS subQuery'
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe SQB::Delete do
  subject(:query) { SQB::Delete.new(:posts) }

  it 'should add columns to update' do
    expect(query.to_sql).to eq 'DELETE FROM `posts`'
  end

  it 'should add where queries' do
    query.where(id: 10)
    expect(query.to_sql).to eq 'DELETE FROM `posts` WHERE (`posts`.`id` = 10)'
  end

  it 'should add ordering' do
    query.where(id: 10)
    query.order(:id, :desc)
    expect(query.to_sql).to eq 'DELETE FROM `posts` WHERE (`posts`.`id` = 10) ORDER BY `posts`.`id` DESC'
  end

  it 'should add a limit' do
    query.limit(10)
    expect(query.to_sql).to eq 'DELETE FROM `posts` LIMIT 10'
  end
end

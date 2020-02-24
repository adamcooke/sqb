# frozen_string_literal: true

require 'spec_helper'

describe SQB::Select do
  subject(:query) { SQB::Select.new(:posts, database_name: 'mydb') }

  context 'database names' do
    it 'should prefix the database name' do
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `mydb`.`posts`'
    end

    it 'should prefix the database name' do
      query.join(:comments, :post_id)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `mydb`.`posts` INNER JOIN `mydb`.`comments` AS `comments_0` ON (`posts`.`id` = `comments_0`.`post_id`)'
    end
  end
end

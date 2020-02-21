require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "joins" do

    it "should allow joins to be added" do
      query.join(:comments, :post_id)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` INNER JOIN `comments` AS `comments_0` ON (`posts`.`id` = `comments_0`.`post_id`)'
    end

    it "should auto name per table" do
      query.join(:comments, :post_id)
      query.join(:tags, :post_id)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` INNER JOIN `comments` AS `comments_0` ON (`posts`.`id` = `comments_0`.`post_id`) INNER JOIN `tags` AS `tags_0` ON (`posts`.`id` = `tags_0`.`post_id`)'
    end

    it "should allow the addition of pre-filtered where options" do
      query.join(:comments, :post_id, :where => {:content => "Hello"})
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` INNER JOIN `comments` AS `comments_0` ON (`posts`.`id` = `comments_0`.`post_id`) WHERE (`comments_0`.`content` = ?)"
    end

    it 'should allow conditions to be added to the join' do
      query.join(:comments, :post_id, :conditions => {:content => "Hello"})
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` INNER JOIN `comments` AS `comments_0` ON (`posts`.`id` = `comments_0`.`post_id` AND `comments_0`.`content` = ?)"
    end

    it "should allow field selection" do
      query.join(:comments, :post_id, :columns => [:content])
      expect(query.to_sql).to eq "SELECT `comments_0`.`content` AS `comments_0_content` FROM `posts` INNER JOIN `comments` AS `comments_0` ON (`posts`.`id` = `comments_0`.`post_id`)"
    end

    it "should allow the join to be named" do
      query.join(:comments, :post_id, :name => :the_comments, :columns => [:content])
      expect(query.to_sql).to eq "SELECT `the_comments`.`content` AS `the_comments_content` FROM `posts` INNER JOIN `comments` AS `the_comments` ON (`posts`.`id` = `the_comments`.`post_id`)"
    end

    it 'should be able to join with other joins' do
      query.join(:user_joins, :post_id, :name => :user_joins, :conditions => {:active => true})
      query.join(:users, [:id, {user_joins: :user_id}], :name => :users)
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` INNER JOIN `user_joins` AS `user_joins` ON (`posts`.`id` = `user_joins`.`post_id` AND `user_joins`.`active` = 1) INNER JOIN `users` AS `users` ON (`user_joins`.`user_id` = `users`.`id`)"
    end

    it 'should allow the local key to be provided too to allow joining to single items' do
      query.join(:users, [:id, :author_id], :name => :users)
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` INNER JOIN `users` AS `users` ON (`posts`.`author_id` = `users`.`id`)"
    end

    it 'should be able to do left joins' do
      query.join(:users, [:id, :author_id], :name => :users, :type => :left)
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` LEFT OUTER JOIN `users` AS `users` ON (`posts`.`author_id` = `users`.`id`)"
    end

    it 'should be able to do right joins' do
      query.join(:users, [:id, :author_id], :name => :users, :type => :right)
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` RIGHT OUTER JOIN `users` AS `users` ON (`posts`.`author_id` = `users`.`id`)"
    end

    it 'should raise an error if you provide an invalid join type' do
      expect do
        query.join(:users, [:id, :author_id], :name => :users, :type => :invalid)
      end.to raise_error(SQB::QueryError) do |e|
        expect(e.message).to match /invalid join type/i
      end
    end

    it 'should be able to tell us if a join has been added' do
      expect(query.has_join?(:users)).to be false
      query.join(:users, :author_id, :name => :users)
      expect(query.has_join?(:users)).to be true
    end

    it 'should be able to tell us if a join has been added when it has no name' do
      expect(query.has_join?(:users_0)).to be false
      query.join(:users, :author_id)
      expect(query.has_join?(:users_0)).to be true
    end

  end

end

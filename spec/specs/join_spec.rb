require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "joins" do

    it "should allow joins to be added" do
      query.join(:comments, :post_id)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` INNER JOIN `comments` AS `comments_0` ON `posts`.`id` = `comments_0`.`post_id`'
    end

    it "should auto name per table" do
      query.join(:comments, :post_id)
      query.join(:tags, :post_id)
      expect(query.to_sql).to eq 'SELECT `posts`.`*` FROM `posts` INNER JOIN `comments` AS `comments_0` ON `posts`.`id` = `comments_0`.`post_id` INNER JOIN `tags` AS `tags_0` ON `posts`.`id` = `tags_0`.`post_id`'
    end

    it "should allow querying" do
      query.join(:comments, :post_id, :where => {:content => "Hello"})
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` INNER JOIN `comments` AS `comments_0` ON `posts`.`id` = `comments_0`.`post_id` WHERE (`comments_0`.`content` = ?)"
    end

    it "should allow field selection" do
      query.join(:comments, :post_id, :columns => [:content])
      expect(query.to_sql).to eq "SELECT `comments_0`.`content` AS `comments_0_content` FROM `posts` INNER JOIN `comments` AS `comments_0` ON `posts`.`id` = `comments_0`.`post_id`"
    end

    it "should allow the join to be named" do
      query.join(:comments, :post_id, :name => :the_comments, :columns => [:content])
      expect(query.to_sql).to eq "SELECT `the_comments`.`content` AS `the_comments_content` FROM `posts` INNER JOIN `comments` AS `the_comments` ON `posts`.`id` = `the_comments`.`post_id`"
    end

  end

end

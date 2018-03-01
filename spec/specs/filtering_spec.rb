require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "filtering" do

    it "should always work on the default table" do
      query.where(:title => 'Hello')
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = ?)"
    end

    it "should be able to query on sub-tables" do
      query.where({:comments => :author} => 'Hello')
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`comments`.`author` = ?)"
    end

    it "should handle searching with array values as numbers" do
      query.where(:author_id => [1,2,3])
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`author_id` IN (1, 2, 3))"
    end

    it "should handle searching with array values as strings" do
      query.where(:author_id => ['Adam', 'Dave', 'John'])
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`author_id` IN (?, ?, ?))"
    end

    it "should handle searching for nils" do
      query.where(:title => nil)
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` IS NULL)"
    end

    it "should allow multiple operators per query" do
      query.where(:views => {:greater_than => 10, :less_than => 100})
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`views` > 10 AND `posts`.`views` < 100)"
    end

    it "should allow safe values to be passed in" do
      query.where(SQB.safe('IF(LENGTH(field2) > 0, field2, field1)') => "Hello")
      expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (IF(LENGTH(field2) > 0, field2, field1) = ?)"
    end

    context "operators" do
      it "should handle equal" do
        query.where(:title => {:equal => 'Hello'})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = ?)"
      end

      it "should handle equal when null" do
        query.where(:title => {:equal => nil})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` IS NULL)"
      end

      it "should handle not equal to" do
        query.where(:title => {:not_equal => 'Hello'})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` != ?)"
      end

      it "should handle not equal to when null" do
        query.where(:title => {:not_equal => nil})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` IS NOT NULL)"
      end

      it "should handle greater than" do
        query.where(:views => {:greater_than => 2})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`views` > 2)"
      end

      it "should handle less than" do
        query.where(:views => {:less_than => 2})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`views` < 2)"
      end

      it "should handle greater than or equal to" do
        query.where(:views => {:greater_than_or_equal_to => 2})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`views` >= 2)"
      end

      it "should handle less than or equal to" do
        query.where(:views => {:less_than_or_equal_to => 2})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`views` <= 2)"
      end

      it "should handle in an array" do
        query.where(:author_id => {:in => [1,2,3]})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`author_id` IN (1, 2, 3))"
      end

      it "should handle not in an array" do
        query.where(:author_id => {:not_in => [1,2,3]})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`author_id` NOT IN (1, 2, 3))"
      end

      it "should handle searching on empty arrays by returning nothing" do
        query.where(:title => 'Hello', :author_id => {:in => []})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`title` = ? AND 1=0)"
      end

      it "should handle like" do
        query.where(:author => {:like => '%Adam'})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`author` LIKE ?)"
      end

      it "should handle not like" do
        query.where(:author => {:not_like => '%Adam'})
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`author` NOT LIKE ?)"
      end

      it "should raise an error when an invalid operator is provided" do
        expect { query.where(:title => {:something => "Hello"})}.to raise_error(SQB::InvalidOperatorError)
      end
    end

    context "or" do
      it "should join with ORs within an or block" do
        query.or do
          query.where(:title => "Hello")
          query.where(:title => "World")
        end
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE ((`posts`.`title` = ?) OR (`posts`.`title` = ?))"
      end
    end

    context "escaping" do
      it "should escape column names" do
        query.where("column`name" => 'Hello')
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`posts`.`column``name` = ?)"
      end

      it "should escape table names" do
        query.where({"table`name" => "title"} => 'Hello')
        expect(query.to_sql).to eq "SELECT `posts`.* FROM `posts` WHERE (`table``name`.`title` = ?)"
      end

    end

  end

end

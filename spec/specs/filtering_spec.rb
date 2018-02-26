require 'spec_helper'

describe SQB::Query do

  subject(:query) { SQB::Query.new(:posts) }

  context "filtering" do

    it "should always work on the default table" do
      query.where(:title => 'Hello')
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` = 'Hello')"
    end

    it "should be able to query on sub-tables" do
      query.where({:comments => :author} => 'Hello')
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`comments`.`author` = 'Hello')"
    end

    it "should handle searching with array values as numbers" do
      query.where(:author_id => [1,2,3])
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`author_id` IN (1, 2, 3))"
    end

    it "should handle searching with array values as strings" do
      query.where(:author_id => ['Adam', 'Dave', 'John'])
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`author_id` IN ('Adam', 'Dave', 'John'))"
    end

    it "should handle searching for nils" do
      query.where(:title => nil)
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` IS NULL)"
    end

    it "should allow multiple operators per query" do
      query.where(:views => {:greater_than => 10, :less_than => 100})
      expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` > 10 AND `posts`.`views` < 100)"
    end

    context "operators" do
      it "should handle equal" do
        query.where(:title => {:equal => 'Hello'})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` = 'Hello')"
      end

      it "should handle equal when null" do
        query.where(:title => {:equal => nil})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` IS NULL)"
      end

      it "should handle not equal to" do
        query.where(:title => {:not_equal => 'Hello'})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` != 'Hello')"
      end

      it "should handle not equal to when null" do
        query.where(:title => {:not_equal => nil})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` IS NOT NULL)"
      end

      it "should handle greater than" do
        query.where(:views => {:greater_than => 2})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` > 2)"
      end

      it "should handle less than" do
        query.where(:views => {:less_than => 2})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` < 2)"
      end

      it "should handle greater than or equal to" do
        query.where(:views => {:greater_than_or_equal_to => 2})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` >= 2)"
      end

      it "should handle less than or equal to" do
        query.where(:views => {:less_than_or_equal_to => 2})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` <= 2)"
      end

      it "should handle in an array" do
        query.where(:author_id => {:in => [1,2,3]})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`author_id` IN (1, 2, 3))"
      end

      it "should handle not in an array" do
        query.where(:author_id => {:not_in => [1,2,3]})
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`author_id` NOT IN (1, 2, 3))"
      end

      it "should raise an error when an invalid operator is provided" do
        expect { query.where(:title => {:something => "Hello"})}.to raise_error(SQB::Error, /invalid operator/i)
      end
    end

    context "or" do
      it "should join with ORs within an or block" do
        query.or do
          query.where(:title => "Hello")
          query.where(:title => "World")
        end
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE ((`posts`.`title` = 'Hello') OR (`posts`.`title` = 'World'))"
      end
    end

    context "escaping" do
      it "should escape column names" do
        query.where("column`name" => 'Hello')
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`column``name` = 'Hello')"
      end

      it "should escape table names" do
        query.where({"table`name" => "title"} => 'Hello')
        expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`table``name`.`title` = 'Hello')"
      end

      context "values" do
        subject(:query) { SQB::Query.new(:posts) { |v| v.to_s.gsub('@', '@@@') } }

        it "should should always escape values" do
          query.where(:title => 'Hello@World')
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` = 'Hello@@@World')"
        end

        it "should should always escape values on arrays" do
          query.where(:title => ['Hello@World', 'Banana@Land'])
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` IN ('Hello@@@World', 'Banana@@@Land'))"
        end

        it "should escape on equal" do
          query.where(:title => {:equal => 'He@llo'})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` = 'He@@@llo')"
        end

        it "should escape on not equal to" do
          query.where(:title => {:not_equal => 'H@ello'})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`title` != 'H@@@ello')"
        end

        it "should escape on greater than" do
          query.where(:views => {:greater_than => '2@2'})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` > '2@@@2')"
        end

        it "should escape on less than" do
          query.where(:views => {:less_than => '2@2'})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` < '2@@@2')"
        end

        it "should escape on greater than or equal to" do
          query.where(:views => {:greater_than_or_equal_to => '2@2'})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` >= '2@@@2')"
        end

        it "should escape on less than or equal to" do
          query.where(:views => {:less_than_or_equal_to => '2@2'})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`views` <= '2@@@2')"
        end

        it "should escape on in an array" do
          query.where(:author_id => {:in => ['H@w', 'A@m']})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`author_id` IN ('H@@@w', 'A@@@m'))"
        end

        it "should escape on not in an array" do
          query.where(:author_id => {:not_in => ['H@w', 'A@m']})
          expect(query.to_sql).to eq "SELECT `posts`.`*` FROM `posts` WHERE (`posts`.`author_id` NOT IN ('H@@@w', 'A@@@m'))"
        end
      end

    end

  end

end

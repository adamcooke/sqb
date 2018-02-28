require 'spec_helper'

describe SQB::Select do

  subject(:query) { SQB::Select.new(:posts) }

  context "grouping" do

    it "should allow a group to be added" do
      query.group_by(:title)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` GROUP BY `posts`.`title`'
    end

    it "should allow multiple groups to be added" do
      query.group_by(:title)
      query.group_by(:content)
      expect(query.to_sql).to eq 'SELECT `posts`.* FROM `posts` GROUP BY `posts`.`title`, `posts`.`content`'
    end

  end

end

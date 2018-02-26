# SQB (SQL Query Builder)

This is a gem that allows you to construct SQL queries from a simple Ruby DSL. There are lots of gems like this around but I haven't yet found one that I really enjoy using that supports things like ORs or various different operators nicely. This isn't a perfect solution but is very handy for quickly generating queries.

## Installation

```ruby
gem 'sqb'
```

## Usage

```ruby
# Create your query and provide a block that can be used to escape string values
# that are provided.
query = SQB::Query.new(:posts) { |v| mysql.escape(v) }

# Generate a query
query.to_sql

# Add some filtering
query.where(:title => "Hello world!")
query.where(:title => {:not_equal => "Hello world!"})
query.where(:title => {:greater_than => 10, less_than => 1000})

# You can do filtering with ORs
query.or do
  query.where(:title => "It might be this")
  query.where(:title => "or it might be this")
end

# You can choose which columns will be returned
query.column(:title)
query.column(:another_column, :as => 'another_name')
query.column(:id, :function => 'COUNT')

# You can add ordering
query.order(:posted_at)
query.order(:posted_at, :asc)
query.order(:posted_at, :desc)

# You can remove all previously added ordering
query.no_order!

# You can remove all previous added ordering and add the current
query.order!(:posted_at)

# You can join to other tables
query.join(:comments, :post_id)

# You can add conditions to the joins
query.join(:comments, :post_id, :where => {:author_id => [1]})

# And you can specify which columns to return from the join
query.join(:comments, :post_id, :columns => [:content, :author_id])

# Don't forget, once you've joined you can use their data in other methods
query.column({:comments => :id}, :function => 'COUNT', :as => :comments_count)
query.where({:comments => :author_id} => [1,2,3,4])

# You can group
query.group_by(:author_id)

# You can limit and offset too
query.limit(10)
query.offset(20)

# Specify that you wish to receive distinct rows
query.distinct
```

# SQB (SQL Query Builder)

[![Build Status](https://travis-ci.org/adamcooke/sqb.svg?branch=master)](https://travis-ci.org/adamcooke/sqb) [![Gem Version](https://badge.fury.io/rb/sqb.svg)](https://badge.fury.io/rb/sqb)

This is a gem that allows you to construct SQL queries from a simple Ruby DSL. There are lots of gems like this around but I haven't yet found one that I really enjoy using that supports things like ORs or various different operators nicely. This isn't a perfect solution but is very handy for quickly generating queries.

## Installation

```ruby
gem 'sqb'
```

## Selecting data

To get started just create yourself a `SQB::Select` object and provide the base table name.

```ruby
query = SQB::Select.new(:posts)
```

When you've done all the operations on the query that you wish to do (see below) you can extract the finished SQL query and prepared arguments for passing to a database client.

```ruby
# Return the SQL query itself
query.to_sql

# Return any arguments needed for the query
query.prepared_arguments

# For example with the MySQL2 client you might do this...
statement = mysql.prepare(query.to_sql)
statement.execute(*query.prepared_arguments)
```

### Filtering

The most common thing you'll want to do is filter the data returned which means using `WHERE`. You can do any of the following to filter the data returned.

```ruby
# The most basic equality operators
query.where(:title => "Hello world!")
query.where(:title => {:equal => "Hello world!"})
query.where(:title => {:not_equal => "Hello world!"})

# Greater than or less than
query.where(:comments_count => {:greater_than => 100})
query.where(:comments_count => {:less_than => 1})
query.where(:comments_count => {:greater_than_or_equal_to => 100})
query.where(:comments_count => {:less_than_or_equal_to => 1})

# Like/Not like
query.where(:body => {:like => "Hello world!"})
query.where(:body => {:not_like => "Hello world!"})

# In/not in an array
query.where(:author_id => [1,2,3,4])
query.where(:author_id => {:in => [1,2,3,4]})
query.where(:author_id => {:not_in => [1,2,3,4]})

# Nulls
query.where(:markdown => nil)
query.where(:markdown => {:not_equal => nil})
```

By default all filtering operations will be joined with ANDs. You can use OR if needed.

```ruby
query.or do
  query.where(:author => "Sarah Smith")
  query.where(:author => "John Jones")
end
```

### Selecting columns

By default, all the columns on your main table will be selected with a `*` however you may not wish to get them all or you may wish to use functions to get other data.

```ruby
query.column(:title)
query.column(:id, :function => 'COUNT', :as => 'count')

# If you have already added columns and wish to replace them all with a new one
query.column!(:other_column)
```

### Specifying orders

You can add fields that you wish to order by as either ascending or decending.

```ruby
query.order(:posted_at)
query.order(:posted_at, :asc)
query.order(:posted_at, :desc)

# If you have already added some orders and wish to replace them with a new field
query.order!(:last_comment_posted_at, :desc)

# To remove all ordering
query.no_order!
```

### Limiting the returned records

You can specify limits and offsets easily

```ruby
query.limit(30)
query.offset(120)
```

### Joining with other tables

To join with other tables you can do so easily with the `join` methods.

```ruby
query.join(:comments, :post_id)
query.join(:comments, :post_id, :name => :comments)
```

By default, this will join with the table but won't return any data. You'll likely want to add some conditions and/or some columns to return.

```ruby
query.join(:comments, :post_id, :columns => [:content])
query.join(:comments, :post_id, :where => {:spam => true})

# You can also use the existing where and column methods to add joins to these tables
query.column({:comments => :spam})
query.where({:comments => :spam} => {:not_equal => true})

# Unless a name is provided with the join, you'll be able to access the join as
# [table_name]_0 (where 0 is an index for the number of joins for that table
# starting with 0).
```

### Grouping

You can, of course, group your data too

```ruby
query.group_by(:author_id)
query.column(:author_id)
query.column(:count, :function => 'COUNT', :as => 'count')
```

### Distinct

To only return distinct rows for your dataset:

```ruby
query.distinct
```

## Updating data

SQB supports crafting UPDATE queries too. You can use the same options for `where` as when selecting data (see above). The `set` method accepts a hash of all values that you wish to update (it can be called multiple times to add additional values).

```ruby
query = SQB::Update.new(:posts)
query.set(:title => 'Hello world!')
query.where(:id => 10)
```

## Deleting data

SQB can write you some lovely DELETE queries too. You can use `where`, `limit` and `order` to limit which records are deleted.

```ruby
query = SQB::Delete.new(:posts)
query.where(:id => 10)
query.limit(10)
query.order(:id => :desc)
```

## Other options

### Specifying a database

You can specify the name of a database that you wish to query. By default, no database name will be included in the query.

```ruby
query = SQB::Query.new(:posts, :database_name => :my_blog)
```

### Inserting arbitary strings

There are occasions where you need to break free from constraints. You can do that by passing strings through the `SQB.safe(string)` method. This will avoid any escaping or clever magic by SQB and the string provided will simply be inserted in the query as appropriate.

```ruby
query.column(SQB.safe('SUM(CEILING(duration / 60))'))
# or
query.where(SQB.safe('IF(LENGTH(excerpt) > 0, excerpt, description)') => {:equal => "Llamas!"})
```

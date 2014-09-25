# Foreigner
[![Build Status](https://travis-ci.org/matthuhiggins/foreigner.png)](https://travis-ci.org/matthuhiggins/foreigner) [![Code Climate](https://codeclimate.com/github/matthuhiggins/foreigner.png)](https://codeclimate.com/github/matthuhiggins/foreigner)

Foreigner introduces a few methods to your migrations for adding and removing foreign key constraints. It also dumps foreign keys to `schema.rb`.

The following adapters are supported:

* mysql2
* postgres
* sqlite (foreign key methods are a no-op)

## Installation

Add the following to your Gemfile:
```ruby
gem 'foreigner'
```
## API Examples

Foreigner adds two methods to migrations.

* `add_foreign_key(from_table, to_table, options)`
* `remove_foreign_key(from_table, to_table, options)`

(Options are documented in `connection_adapters/abstract/schema_statements.rb`):

For example, given the following model:
```ruby
class Comment < ActiveRecord::Base
  belongs_to :post
end

class Post < ActiveRecord::Base
  has_many :comments, dependent: :delete_all
end
```  
You should add a foreign key in your migration:
```ruby
add_foreign_key(:comments, :posts)
```
The `:dependent` option can be moved from the `has_many` definition to the foreign key:
```ruby
add_foreign_key(:comments, :posts, dependent: :delete)
```
If the column is named `article_id` instead of `post_id`, use the `:column` option:
```ruby
add_foreign_key(:comments, :posts, column: 'article_id')
```
A name can be specified for the foreign key constraint:
```ruby
add_foreign_key(:comments, :posts, name: 'comment_article_foreign_key')
```
The `:column` and `:name` options create a foreign key with a custom name. In order to remove it you need to specify `:name`:
```ruby
remove_foreign_key(:comments, name: 'comment_article_foreign_key')
```
## Change Table Methods

Foreigner adds extra methods to `create_table` and `change_table`.

Create a new table with a foreign key:
```ruby
create_table :products do |t|
  t.string :name
  t.integer :factory_id
  t.foreign_key :factories
end
```
Add a missing foreign key to comments:
```ruby
change_table :comments do |t|
  t.foreign_key :posts, dependent: :delete
end
```
Remove an unwanted foreign key:
```ruby
change_table :comments do |t|
  t.remove_foreign_key :users
end
```
## Database-specific options

Database-specific options will never be supported by foreigner. You can add them using `:options`:
```ruby
add_foreign_key(:comments, :posts, options: 'ON UPDATE DEFERRED')
```
## Foreigner Add-ons

* [immigrant](https://github.com/jenseng/immigrant) - generate a migration that includes all missing foreign keys.
* [sqlserver-foreigner](https://github.com/cleblanc87/sqlserver-foreigner) - A plugin for SQL Server.

## License

Copyright (c) 2012 Matthew Higgins, released under the MIT license

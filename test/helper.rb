require 'bundler/setup'
Bundler.require(:default)

require 'test/unit'
require 'active_record'
require 'mocha'

# Foreigner::Adapter.registered.values.each do |file_name|
#   require file_name
# end

module TestAdapterMethods
  def execute(sql, name = nil)
    sql_statements << sql
    sql
  end
  
  def quote_table_name(name)
    quote_column_name(name).gsub('.', '`.`')
  end

  def quote_column_name(name)
    "`#{name}`"
  end

  def sql_statements
    @sql_statements ||= []
  end

  def drop_table(name, options = {})  
  end

  def disable_referential_integrity
    @disable_referential_integrity = true
    yield
  end

  private
    def execute(sql, name = nil)
      sql_statements << sql
      sql
    end
end

module Foreigner
  class UnitTest < ActiveSupport::TestCase
  end

  class IntegrationTest < ActiveSupport::TestCase
    def with_migration(&blk)
      migration = Class.new(ActiveRecord::Migration)

      migration.singleton_class do
        define_method(:up, &blk)
      end

      migration
    end
  end
end
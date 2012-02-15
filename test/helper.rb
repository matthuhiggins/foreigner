require 'bundler/setup'
Bundler.require(:default)

require 'test/unit'
require 'active_record'

# Foreigner::Adapter.registered.values.each do |file_name|
#   require file_name
# end

class TestAdapter
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
require 'rubygems'
require 'test/unit'
require 'rails/all'

require 'foreigner'

Foreigner::Adapter.registered.values.each do |file_name|
  require file_name
end

module Foreigner
  class UnitTest < ActiveSupport::TestCase
    private
      def execute(sql, name = nil)
        sql
      end

      def quote_column_name(name)
        "`#{name}`"
      end

      def quote_table_name(name)
        quote_column_name(name).gsub('.', '`.`')
      end
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
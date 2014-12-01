require 'helper'
require 'foreigner/connection_adapters/mysql2_adapter'

class Foreigner::Mysql2AdapterTest < Foreigner::UnitTest
  class Mysql2Adapter
    include TestAdapterMethods
    include Foreigner::ConnectionAdapters::Mysql2Adapter
  end

  setup do
    @adapter = Mysql2Adapter.new
    @adapter.instance_variable_set(:@config, database: 'foo')
  end

  test 'foreign_keys parsing' do
    @adapter.expects(:select_all).at_least_once.returns([
      {'column' => 'foo_id', 'name' => 'foo_bar_foo_id_fk', 'primary_key' => 'id', 'to_table' => 'foo'}
    ])

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`)\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent:nil, options:nil}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`),\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent:nil, options:nil}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`) ON DELETE CASCADE\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent: :delete, options:nil}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`) ON DELETE CASCADE,\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent: :delete, options:nil}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`) FOO BAR\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent:nil, options:'FOO BAR'}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`) FOO BAR,\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent:nil, options:'FOO BAR'}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`) ON DELETE CASCADE FOO BAR,\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent: :delete, options:'FOO BAR'}),
                 @adapter.foreign_keys('bar').first

    @adapter.expects(:select_one).returns('Create Table' => "CONSTRAINT `foo_bar_foo_id_fk` FOREIGN KEY (`foo_id`) REFERENCES `foo` (`id`) ON DELETE CASCADE FOO BAR,\n")
    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent: :delete, options:'FOO BAR'}),
                 @adapter.foreign_keys('bar').first
  end

  test 'remove_foreign_key_sql by table' do
    assert_equal(
      "DROP FOREIGN KEY `suppliers_company_id_fk`",
      @adapter.remove_foreign_key_sql(:suppliers, :companies)
    )
  end

  test 'remove_foreign_key_sql by name' do
    assert_equal(
      "DROP FOREIGN KEY `belongs_to_supplier`",
      @adapter.remove_foreign_key_sql(:suppliers, name: "belongs_to_supplier")
    )
  end

  test 'remove_foreign_key_sql by column' do
    assert_equal(
      "DROP FOREIGN KEY `suppliers_ship_to_id_fk`",
      @adapter.remove_foreign_key_sql(:suppliers, column: "ship_to_id")
    )
  end
end

require 'helper'

class Foreigner::SchemaDumperTest < Foreigner::UnitTest

  class MockConnection
    def tables
      [ 'foo', 'bar' ]
    end
  end

  class MockSchemaDumper
    cattr_accessor :ignore_tables

    attr_accessor :processed_tables, :stream
    def initialize
      @connection = MockConnection.new
      @processed_tables = []
    end

    def tables(stream)
    end

    def foreign_keys(table, stream)
      self.stream = stream
      processed_tables << table
    end

    include Foreigner::SchemaDumper
  end

  test 'dump_foreign_key' do
    assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\"", Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('foos', 'bars', column: 'bar_id', primary_key: 'id', name: 'lulz')
    assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\", primary_key: \"uuid\"", Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('foos', 'bars', column: 'bar_id', primary_key: 'uuid', name: 'lulz')
    assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\", dependent: :delete", Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('foos', 'bars', column: 'bar_id', primary_key: 'id', name: 'lulz', dependent: :delete)
    assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\", column: \"mamma_id\"", Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('foos', 'bars', column: 'mamma_id', primary_key: 'id', name: 'lulz')
    assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\", options: \"YOLO MAYBE DB-SPECIFIC!\"", Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('foos', 'bars', column: 'bar_id', primary_key: 'id', name: 'lulz', options: "YOLO MAYBE DB-SPECIFIC!")
    assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\", column: [\"a_id\", \"b_id\"], primary_key: [\"c_id\", \"d_id\"]",
    Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('foos',
    'bars', column: ['a_id', 'b_id'], primary_key: ['c_id', 'd_id'],
    name: 'lulz')
  end

  test 'all tables' do
    MockSchemaDumper.ignore_tables = []
    dumper = MockSchemaDumper.new
    dumper.tables(StringIO.new)
    assert_equal ['bar', 'foo'].to_set, dumper.processed_tables.to_set
  end

  test 'ignores tables' do
    MockSchemaDumper.ignore_tables = ['foo']
    dumper = MockSchemaDumper.new
    dumper.tables(StringIO.new)
    assert_equal ['bar'].to_set, dumper.processed_tables.to_set
  end

  test '4.1.9 loading error' do
    Foreigner::Helper.stubs(:active_record_version).returns Gem::Version.new("4.1.9")
    MockSchemaDumper.ignore_tables = []
    dumper = MockSchemaDumper.new
    dumper.tables(StringIO.new)

    assert_match(/Foreigner\.load/, dumper.stream.string)
  end

  test 'removes table name suffix and prefix' do
    begin
      ActiveRecord::Base.table_name_prefix = 'pre_'
      ActiveRecord::Base.table_name_suffix = '_suf'
      assert_dump "add_foreign_key \"foos\", \"bars\", name: \"lulz\"", Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('pre_foos_suf', 'pre_bars_suf', column: 'bar_id', primary_key: 'id', name: 'lulz')
    ensure
      ActiveRecord::Base.table_name_suffix = ActiveRecord::Base.table_name_prefix = ''
    end
  end

  private
    def assert_dump(expected, definition)
      assert_equal expected, MockSchemaDumper.dump_foreign_key(definition)
    end
end


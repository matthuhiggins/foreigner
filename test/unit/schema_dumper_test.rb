require 'helper'

class Foreigner::SchemaDumperTest < Foreigner::UnitTest

  class MockConnection
    def tables
      [ 'foo', 'bar' ]
    end
  end

  class MockSchemaDumper
    cattr_accessor :ignore_tables, :processed_tables
    @@ignore_table = []
    @@processed_tables = []

    @connection = MockConnection.new

    # need this here so ActiveRecord::Concern has something to redefine
    def tables
    end

    include Foreigner::SchemaDumper

    # override this method so we don't have to mock up
    # all of the necessary scafolding for things to work
    def foreign_keys(table, stream)
      processed_tables << table
    end

    def tables(ignore_list)
      ignore_tables = ignore_list
      processed_table = nil
    end
  end

  test 'returns_all_tables' do
    assert MockSchemaDumper.new(nil).processed_tables.sort.to_s, "['bar', 'foo']"
  end

  test 'only_returns_1_table' do
    assert MockSchemaDumper.new('foo').processed_tables.to_s, "['bar']"
  end
end


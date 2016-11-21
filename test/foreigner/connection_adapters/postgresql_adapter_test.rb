require 'helper'
require 'foreigner/connection_adapters/postgresql_adapter'

class Foreigner::PostgreSQLAdapterTest < Foreigner::UnitTest
  class PostgreSQLAdapter
    include TestAdapterMethods
    include Foreigner::ConnectionAdapters::PostgreSQLAdapter
  end

  setup do
    @adapter = PostgreSQLAdapter.new
  end

  test 'foreign_keys parsing' do
    @adapter.expects(:postgresql_version).at_least_once.returns(90404)
    @adapter.expects(:select_all).with(%{
          SELECT t2.relname AS to_table
               , a1.attname AS column
               , a2.attname AS primary_key
               , c.conname AS name
               , c.confdeltype AS dependency
               , c.confupdtype AS update_dependency
               , c.condeferrable AS deferrable
               , c.condeferred AS deferred
            , c.convalidated AS valid
          FROM pg_constraint c
          JOIN pg_class t1 ON c.conrelid = t1.oid
          JOIN pg_class t2 ON c.confrelid = t2.oid
          JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
          JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
          JOIN pg_namespace t3 ON c.connamespace = t3.oid
          WHERE c.contype = 'f'
            AND t1.relname = 'bar'
            AND t3.nspname = ANY (current_schemas(false))
          ORDER BY c.conname
        }).at_least_once.returns([{'column' => 'foo_id', 'name' => 'foo_bar_foo_id_fk', 'primary_key' => 'id', 'to_table' => 'foo'}])

    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent:nil, options:""}),
                 @adapter.foreign_keys('bar').first
  end

  test 'foreign_keys parsing with schema specified' do
    @adapter.expects(:postgresql_version).at_least_once.returns(90404)
    @adapter.expects(:select_all).with(%{
          SELECT t2.relname AS to_table
               , a1.attname AS column
               , a2.attname AS primary_key
               , c.conname AS name
               , c.confdeltype AS dependency
               , c.confupdtype AS update_dependency
               , c.condeferrable AS deferrable
               , c.condeferred AS deferred
            , c.convalidated AS valid
          FROM pg_constraint c
          JOIN pg_class t1 ON c.conrelid = t1.oid
          JOIN pg_class t2 ON c.confrelid = t2.oid
          JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
          JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
          JOIN pg_namespace t3 ON c.connamespace = t3.oid
          WHERE c.contype = 'f'
            AND t1.relname = 'bar'
            AND t3.nspname = 'public'
          ORDER BY c.conname
        }).at_least_once.returns([{'column' => 'foo_id', 'name' => 'foo_bar_foo_id_fk', 'primary_key' => 'id', 'to_table' => 'foo'}])

    assert_equal Foreigner::ConnectionAdapters::ForeignKeyDefinition.new('public.bar', 'foo', {column:"foo_id", name:"foo_bar_foo_id_fk", primary_key:"id", dependent:nil, options:""}),
                 @adapter.foreign_keys('public.bar').first

  end
end

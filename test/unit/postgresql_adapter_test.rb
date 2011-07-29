require 'helper'
require 'foreigner/connection_adapters/postgresql_adapter'

class Foreigner::PostgreSQLAdapterTest < Foreigner::UnitTest
  include Foreigner::ConnectionAdapters::PostgreSQLAdapter

  test 'drop_table' do
    assert_equal(
      "DROP TABLE `widgets` CASCADE",
      drop_table(:widgets)
    )
  end
end
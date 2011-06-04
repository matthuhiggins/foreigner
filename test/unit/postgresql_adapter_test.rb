require 'helper'

class Foreigner::PostgreSQLAdapterTest < Foreigner::UnitTest
  include Foreigner::ConnectionAdapters::PostgreSQLAdapter

  test 'drop_table' do
    assert_equal(
      "DROP TABLE `widgets` CASCADE",
      drop_table(:widgets)
    )
  end
end
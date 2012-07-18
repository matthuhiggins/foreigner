require 'helper'

class Foreigner::MysqlAdapterTest < Foreigner::UnitTest
  test 'warning' do
    output = capture(:stdout) do
      require 'foreigner/connection_adapters/mysql_adapter'
    end
    assert_match /WARNING: Please upgrade to mysql2. The old mysql adapter is not supported by foreigner./, output
  end
end
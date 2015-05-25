require 'helper'

class Foreigner::MysqlAdapterTest < Foreigner::UnitTest
  test 'warning' do
    output = StringIO.new
    with_stdout(output) do
      require 'foreigner/connection_adapters/mysql_adapter'
    end
    assert_match /WARNING: Please upgrade to mysql2. The old mysql adapter is not supported by foreigner./, output.string
  end
end

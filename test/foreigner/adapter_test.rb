require 'helper'

class Foreigner::AdapterTest < Foreigner::UnitTest
  test "load" do
    Foreigner::Adapter.register 'foo', 'bar'
    Foreigner::Adapter.expects(:configured_name).at_least_once.returns('foo')
    Foreigner::Adapter.expects(:require).with('bar')

    Foreigner::Adapter.load!
  end

  test "load prints warning message for an unsupported adapter on two lines" do
    Foreigner::Adapter.stubs(:configured_name).returns('unsupported')

    output = StringIO.new
    with_stdout(output) { Foreigner::Adapter.load! }

    assert_equal 2, output.string.split("\n").length
  end
end

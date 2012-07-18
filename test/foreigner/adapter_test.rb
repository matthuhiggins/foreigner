require 'helper'

class Foreigner::AdapterTest < ActiveSupport::TestCase
  test "load" do
    Foreigner::Adapter.register 'foo', 'bar'
    Foreigner::Adapter.expects(:configured_name).at_least_once.returns('foo')
    Foreigner::Adapter.expects(:require).with('bar')

    Foreigner::Adapter.load!
  end
end
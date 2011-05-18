require 'helper'

class ReversibleTest < Foreigner::AdapterTest
  include Foreigner::ConnectionAdapters::Mysql2Adapter
  ActiveRecord::Migration::CommandRecorder.class_eval do
    include Foreigner::Migration::CommandRecorder
  end
  
  test 'invert_remove_foreign_key' do
    recorder = ActiveRecord::Migration::CommandRecorder.new
    recorded = recorder.add_foreign_key(:table1, :table2)[0]
    assert_equal(
      send(recorded[0], *recorded[1]),
      send(*recorder.invert_remove_foreign_key(:table1, :table2))
    )
  end
  test 'invert_remove_foreign_key with column' do
    recorder = ActiveRecord::Migration::CommandRecorder.new
    recorded = recorder.add_foreign_key(:table1, :table2, :column => :column1)[0]
    assert_equal(
      send(recorded[0], *recorded[1]),
      send(*recorder.invert_remove_foreign_key(:table1, :table2, :column => :column1))
    )
  end
  test 'invert_add_foreign_key' do
    recorder = ActiveRecord::Migration::CommandRecorder.new
    recorded = recorder.remove_foreign_key(:table1, :table2)[0]
    assert_equal(
      send(recorded[0], *recorded[1]),
      send(*recorder.invert_add_foreign_key(:table1, :table2))
    )
  end
  test 'invert_add_foreign_key with column' do
    recorder = ActiveRecord::Migration::CommandRecorder.new
    recorded = recorder.remove_foreign_key(:table1, :table2, :column => :column1)[0]
    assert_equal(
      send(recorded[0], *recorded[1]),
      send(*recorder.invert_add_foreign_key(:table1, :table2, :column => :column1))
    )
  end
  
end
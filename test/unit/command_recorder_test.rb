require 'helper'

ActiveRecord::Migration::CommandRecorder.class_eval do
  include ::Foreigner::Migration::CommandRecorder
end

class Foreigner::CommandRecorderTest < Foreigner::UnitTest
  def setup
    @recorder = ActiveRecord::Migration::CommandRecorder.new
  end

  test 'invert_add_foreign_key' do
    @recorder.add_foreign_key(:employees, :companies)
    remove = @recorder.inverse.first
    assert_equal [:remove_foreign_key, [:employees, :companies]], remove
  end

  test 'invert_add_foreign_key with column' do
    @recorder.add_foreign_key(:employees, :companies, :column => :place_id)
    remove = @recorder.inverse.first
    assert_equal [:remove_foreign_key, [:employees, {:column => :place_id}]], remove
  end

  test 'invert_add_foreign_key with name' do
    @recorder.add_foreign_key(:employees, :companies, :name => 'the_best_fk', :column => :place_id)
    remove = @recorder.inverse.first
    assert_equal [:remove_foreign_key, [:employees, {:name => 'the_best_fk'}]], remove
    
    @recorder.record :rename_table, [:old, :new]
    rename = @recorder.inverse.first
    assert_equal [:rename_table, [:new, :old]], rename
  end

  test 'remove_foreign_key is irreversible' do
    @recorder.remove_foreign_key(:employees, :companies)
    assert_raise ActiveRecord::IrreversibleMigration do
      @recorder.inverse
    end
  end
end
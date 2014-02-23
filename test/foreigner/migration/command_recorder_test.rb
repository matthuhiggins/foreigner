require 'helper'

if defined?(ActiveRecord::Migration::CommandRecorder)
  ActiveRecord::Migration::CommandRecorder.class_eval do
    include ::Foreigner::Migration::CommandRecorder
  end
end

class Foreigner::CommandRecorderTest < Foreigner::UnitTest

  def revert_exists?
    defined?(ActiveRecord::Migration::CommandRecorder) &&
      ActiveRecord::Migration::CommandRecorder.instance_methods.include?(:revert)
  end

  setup do
    skip unless revert_exists?
    @recorder = ActiveRecord::Migration::CommandRecorder.new
  end

  test 'invert_add_foreign_key' do
    @recorder.revert do
      @recorder.add_foreign_key(:employees, :companies)
    end

    assert_equal [
      [:remove_foreign_key, [:employees, :companies]]
    ], @recorder.commands
  end

  test 'invert_add_foreign_key with column' do
    @recorder.revert do
      @recorder.add_foreign_key(:employees, :companies, column: :place_id)
    end

    assert_equal [
      [:remove_foreign_key, [:employees, {column: :place_id}]]
    ], @recorder.commands
  end

  test 'invert_add_foreign_key with name' do
    @recorder.revert do
      @recorder.add_foreign_key(:employees, :companies, name: 'the_best_fk', column: :place_id)
    end

    assert_equal [
      [:remove_foreign_key, [:employees, {name: 'the_best_fk'}]]
    ], @recorder.commands
  end

  test 'remove_foreign_key is irreversible' do
    assert_raise ActiveRecord::IrreversibleMigration do
      @recorder.revert do
        @recorder.remove_foreign_key(:employees, :companies)
      end
    end
      # @recorder.inverse
    # end
  end
end

require 'helper'
require 'foreigner/connection_adapters/postgresql_adapter'

class Foreigner::PostgreSQLAdapterTest < Foreigner::UnitTest
  class TestAdapter
    include TestAdapterMethods
    include Foreigner::ConnectionAdapters::PostgreSQLAdapter
  end

  setup do
    @adapter = TestAdapter.new
  end

  test 'add_with_deferrable' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "DEFERRABLE",
      @adapter.add_foreign_key(:employees, :companies, :options => "DEFERRABLE")
    )
  end

  test 'add_with_initially_deferred' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "INITIALLY DEFERRED",
      @adapter.add_foreign_key(:employees, :companies, :options => "INITIALLY DEFERRED")
    )
  end

  test 'add_with_both_deferred_and_initially_deferred' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "DEFERRABLE " +
      "INITIALLY DEFERRED",
      @adapter.add_foreign_key(:employees, :companies, :options => "DEFERRABLE INITIALLY DEFERRED")
    )
  end
end

require 'helper'

class Foreigner::Sql2003Test < Foreigner::UnitTest
  class TestAdapter
    include TestAdapterMethods
    include Foreigner::ConnectionAdapters::Sql2003
  end

  setup do
    @adapter = TestAdapter.new
  end

  test 'drop_table without force' do
    @adapter.drop_table 'shoes'
    assert !@adapter.instance_variable_get(:@disable_referential_integrity)
  end

  test 'drop_table with force' do
    @adapter.drop_table 'shoes', force: true
    assert @adapter.instance_variable_get(:@disable_referential_integrity)
  end

  test 'add_without_options' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)",
      @adapter.add_foreign_key(:employees, :companies)
    )
  end
  
  test 'add_with_name' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `favorite_company_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id)",
      @adapter.add_foreign_key(:employees, :companies, :name => 'favorite_company_fk')
    )
  end
  
  test 'add_with_column' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_last_employer_id_fk` FOREIGN KEY (`last_employer_id`) REFERENCES `companies`(id)",
      @adapter.add_foreign_key(:employees, :companies, :column => 'last_employer_id')
    ) 
  end
  
  test 'add_with_column_and_name' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `favorite_company_fk` FOREIGN KEY (`last_employer_id`) REFERENCES `companies`(id)",
      @adapter.add_foreign_key(:employees, :companies, :column => 'last_employer_id', :name => 'favorite_company_fk')
    )
  end
  
  test 'add_with_delete_dependency' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE CASCADE",
      @adapter.add_foreign_key(:employees, :companies, :dependent => :delete)
    )
  end
  
  test 'add_with_nullify_dependency' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE SET NULL",
      @adapter.add_foreign_key(:employees, :companies, :dependent => :nullify)
    )
  end
  
  test 'add_with_restrict_dependency' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON DELETE RESTRICT",
      @adapter.add_foreign_key(:employees, :companies, :dependent => :restrict)
    )
  end

  test 'add_with_options' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "on delete foo",
      @adapter.add_foreign_key(:employees, :companies, :options => 'on delete foo')
    )
  end
  
  test 'remove_by_table' do
    assert_equal(
      "ALTER TABLE `suppliers` DROP CONSTRAINT `suppliers_company_id_fk`",
      @adapter.remove_foreign_key(:suppliers, :companies)
    )
  end
  
  test 'remove_by_name' do
    assert_equal(
      "ALTER TABLE `suppliers` DROP CONSTRAINT `belongs_to_supplier`",
      @adapter.remove_foreign_key(:suppliers, :name => "belongs_to_supplier")
    )
  end
  
  test 'remove_by_column' do
    assert_equal(
      "ALTER TABLE `suppliers` DROP CONSTRAINT `suppliers_ship_to_id_fk`",
      @adapter.remove_foreign_key(:suppliers, :column => "ship_to_id")
    )
  end
  
  # Update action tests:  
  test 'add_with_restrict_action' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON UPDATE RESTRICT",
      @adapter.add_foreign_key(:employees, :companies, :on_update => :restrict)
    )
  end
  
  test 'add_with_cascade_action' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON UPDATE CASCADE",
      @adapter.add_foreign_key(:employees, :companies, :on_update => :cascade)
    )
  end
  
  test 'add_with_set_null_action' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON UPDATE SET NULL",
      @adapter.add_foreign_key(:employees, :companies, :on_update => :set_null)
    )
  end
  
  test 'add_with_set_default_action' do
    assert_equal(
      "ALTER TABLE `employees` ADD CONSTRAINT `employees_company_id_fk` FOREIGN KEY (`company_id`) REFERENCES `companies`(id) " +
      "ON UPDATE SET DEFAULT",
      @adapter.add_foreign_key(:employees, :companies, :on_update => :set_default)
    )
  end
end
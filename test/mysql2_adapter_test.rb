require 'helper'

class Mysql2AdapterTest < Foreigner::AdapterTest
  include Foreigner::ConnectionAdapters::Mysql2Adapter

  test 'remove_by_table' do
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `suppliers_company_id_fk`",
      remove_foreign_key(:suppliers, :companies)
    )
  end
  
  test 'remove_by_name' do
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `belongs_to_supplier`",
      remove_foreign_key(:suppliers, :name => "belongs_to_supplier")
    )
  end
  
  test 'remove_by_column' do
    assert_equal(
      "ALTER TABLE `suppliers` DROP FOREIGN KEY `suppliers_ship_to_id_fk`",
      remove_foreign_key(:suppliers, :column => "ship_to_id")
    )
  end
end
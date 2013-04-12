require 'helper'
require 'foreigner/connection_adapters/mysql2_adapter'

class Foreigner::Mysql2AdapterTest < Foreigner::UnitTest
  class Mysql2Adapter
    include TestAdapterMethods
    include Foreigner::ConnectionAdapters::Mysql2Adapter
  end

  setup do
    @adapter = Mysql2Adapter.new
  end

  test 'remove_foreign_key_sql by table' do
    assert_equal(
      "DROP FOREIGN KEY `suppliers_company_id_fk`",
      @adapter.remove_foreign_key_sql(:suppliers, :companies)
    )
  end
  
  test 'remove_foreign_key_sql by name' do
    assert_equal(
      "DROP FOREIGN KEY `belongs_to_supplier`",
      @adapter.remove_foreign_key_sql(:suppliers, :name => "belongs_to_supplier")
    )
  end
  
  test 'remove_foreign_key_sql by column' do
    assert_equal(
      "DROP FOREIGN KEY `suppliers_ship_to_id_fk`",
      @adapter.remove_foreign_key_sql(:suppliers, :column => "ship_to_id")
    )
  end
  
  test 'extract_on_update_action_for_for' do
    sample_create_table_info = """CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(120) NOT NULL,
  `password` varchar(64) DEFAULT NULL,
  `passwordSalt` varchar(64) DEFAULT NULL,
  `other_auth_provider` varchar(10) DEFAULT NULL,
  `other_auth_id` varchar(200) DEFAULT NULL,
  `full_name` varchar(150) DEFAULT NULL,
  `postcode` varchar(100) DEFAULT NULL,
  `test_truckerType_id` int(10) unsigned DEFAULT NULL COMMENT 'Some gibberish.',
  `test_main_photo` int(10) unsigned DEFAULT NULL,
  `test_shortDescription` varchar(150) DEFAULT NULL,
  `test_promotionalTitle` varchar(200) DEFAULT NULL COMMENT 'Some mote erkj skajds kdjns ajdthe ''featured'' sdsa kdjsasd sakdjsdk.',
  `test_thumbnailPhoto` int(10) unsigned DEFAULT NULL,
  `test_promotionalSummary` varchar(400) DEFAULT NULL COMMENT 'This is displayed on the ds dsf dsf dsf sd''s page, under the fdsfd fd fsdf df dsfds.',
  `admin_rights` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'l kfdsjdflkdsfnldsk fdkslfn dsklf ndkfdsl. Here''s a list:\n0x1 - root (full permissions to do anything)',
  `test_homepage_photo` int(10) unsigned DEFAULT NULL,
  `test_homepage_thumbnail` int(10) unsigned DEFAULT NULL,
  `test_homepage_feature_photo` int(10) unsigned DEFAULT NULL,
  `randomId` varchar(120) DEFAULT NULL,
  `isDeleted` tinyint(1) NOT NULL DEFAULT '0',
  `paypal_merchant_email` varchar(255) DEFAULT NULL,
  `password_reset_hash` varchar(80) DEFAULT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT '0',
  `approved_date` datetime DEFAULT NULL,
  `approval_note` varchar(120) DEFAULT NULL,
  `created_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `optInEmail` tinyint(4) NOT NULL DEFAULT '0',
  `truckerTypes_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `idx_randomId` (`randomId`) USING HASH,
  UNIQUE KEY `idx_password_reset_hash_idx` (`password_reset_hash`),
  KEY `fk_users_truckerType1_idx` (`test_truckerType_id`),
  KEY `fk_users_photos1_idx` (`test_main_photo`),
  KEY `fk_users_photos2_idx` (`test_thumbnailPhoto`),
  KEY `fk_users_photos3_idx` (`test_homepage_photo`),
  KEY `fk_users_photos4_idx` (`test_homepage_thumbnail`),
  KEY `fk_users_photos5_idx` (`test_homepage_feature_photo`),
  KEY `idx_users_other_auth_id` (`other_auth_id`),
  KEY `fk_users_truckerTypes1_idx` (`truckerTypes_id`),
  CONSTRAINT `fk_users_photos5` FOREIGN KEY (`test_homepage_feature_photo`) REFERENCES `photos` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_users_truckerTypes1` FOREIGN KEY (`truckerTypes_id`) REFERENCES `truckerTypes` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_users_photos1` FOREIGN KEY (`test_main_photo`) REFERENCES `photos` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_photos2` FOREIGN KEY (`test_thumbnailPhoto`) REFERENCES `photos` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  CONSTRAINT `fk_users_photos3` FOREIGN KEY (`test_homepage_photo`) REFERENCES `photos` (`id`) ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_photos4` FOREIGN KEY (`test_homepage_thumbnail`) REFERENCES `photos` (`id`) ON DELETE NO ACTION,
  CONSTRAINT `fk_users_truckerType1` FOREIGN KEY (`test_truckerType_id`) REFERENCES `truckerTypes` (`id`) ON DELETE CASCADE ON UPDATE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=1332 DEFAULT CHARSET=latin1
"""
    assert_equal(
      :cascade,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_photos5')
    )
    assert_equal(
      :cascade,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_truckerTypes1')
    )
    assert_equal(
      :cascade,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_photos2')
    )
    assert_equal(
      :none,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_photos1')
    )
    assert_equal(
      :none,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_photos3')
    )
    assert_equal(
      nil,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_photos4')
    )
    assert_equal(
      :set_null,
      @adapter.extract_on_update_for_row(sample_create_table_info, 'fk_users_truckerType1')
    )
  end
end
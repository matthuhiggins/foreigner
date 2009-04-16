module Foreigner
  module AdapterMethods
    def supports_foreign_keys?
      false
    end
    
    # Adds a new foreign key to the +from_table+, referencing the primary key of +to_table+
    #
    # The foreign key will be named after the from and to tables unless you pass
    # <tt>:name</tt> as an option.
    #
    # ===== Examples
    # ====== Creating a foreign key
    #  add_foreign_key(:comments, :posts)
    # generates
    #  ALTER TABLE `comments` ADD CONSTRAINT
    #     `comments_post_id_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
    # 
    # ====== Removing a foreign key
    #  remove_foreign_key(:comments, :posts)
    # generates
    #  ALTER TABLE `comments` DROP FOREIGN KEY `comments_post_id_fk`
    # 
    # 
    # === Supported options
    # [:column]
    #   Specify the column name on the from_table that references the to_table. By default this is guessed
    #   to be the singular name of the to_table with "_id" suffixed. So a to_table of :posts will use "post_id"
    #   as the default <tt>:column</tt>.
    # [:name]
    #   Specify the name of the foreign key constraint. This defaults to use the from table and column.
    # [:dependent]
    #   If set to <tt>:delete</tt>, the associated records in from_table are deleted when records in to_table table are deleted.
    #   If set to <tt>:nullify</tt>, the from_table column is set to +NULL+.
    def add_foreign_key(from_table, to_table, options = {})
    end
    
    # Remove the given foreign key from the table.
    #
    # ===== Examples
    # ====== Remove the suppliers_company_id_fk in the suppliers table.
    #   remove_foreign_key :suppliers, :companies
    # ====== Remove the foreign key named accounts_branch_id_fk in the accounts table.
    #   remove_foreign_key :accounts, :column => :branch_id
    # ====== Remove the foreign key named party_foreign_key in the accounts table.
    #   remove_foreign_key :accounts, :name => :party_foreign_key
    def remove_foreign_key(from_table, options)
    end
  end
end

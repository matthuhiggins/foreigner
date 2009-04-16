module Foreigner
  module TableMethods
    # Adds a new foreign key to the table. +column_name+ can be a single Symbol, or
    # an Array of Symbols. See SchemaStatements#add_foreign_key
    #
    # ===== Examples
    # ====== Creating a simple foreign key
    #  t.foreign_key(:people)
    # ====== Defining the column
    #  t.foreign_key(:people, :column => :sender_id)
    # ====== Creating a named foreign key
    #  t.foreign_key(:people, :column => :sender_id, :name => 'sender_foreign_key')
    def foreign_key(table, options = {})
      @base.add_foreign_key(@table_name, table, options)
    end
    
    # Remove the given foreign key from the table.
    #
    # ===== Examples
    # ====== Remove the suppliers_company_id_fk in the suppliers table.
    #   t.remove_foreign_key :companies
    # ====== Remove the foreign key named accounts_branch_id_fk in the accounts table.
    #   remove_foreign_key :column => :branch_id
    # ====== Remove the foreign key named party_foreign_key in the accounts table.
    #   remove_index :name => :party_foreign_key
    def remove_foreign_key(options = {})
      @base.remove_foreign_key(@table_name, options)
    end
  end
end

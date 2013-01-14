module Foreigner
  module ConnectionAdapters    
    module Table
      extend ActiveSupport::Concern

      included do
        alias_method_chain :references, :foreign_keys
      end

      # Adds a new foreign key to the table. +to_table+ can be a single Symbol, or
      # an Array of Symbols. See SchemaStatements#add_foreign_key
      #
      # ===== Examples
      # ====== Creating a simple foreign key
      #  t.foreign_key(:people)
      # ====== Defining the column
      #  t.foreign_key(:people, column: :sender_id)
      # ====== Creating a named foreign key
      #  t.foreign_key(:people, column: :sender_id, name: 'sender_foreign_key')
      # ====== Defining the column of the +to_table+.
      #  t.foreign_key(:people, column: :sender_id, primary_key: :person_id)
      def foreign_key(to_table, options = {})
        @base.add_foreign_key(@table_name, to_table, options)
      end

      # Remove the given foreign key from the table.
      #
      # ===== Examples
      # ====== Remove the suppliers_company_id_fk in the suppliers table.
      #   change_table :suppliers do |t|
      #     t.remove_foreign_key :companies
      #   end
      # ====== Remove the foreign key named accounts_branch_id_fk in the accounts table.
      #   change_table :accounts do |t|
      #     t.remove_foreign_key column: :branch_id
      #   end
      # ====== Remove the foreign key named party_foreign_key in the accounts table.
      #   change_table :accounts do |t|
      #     t.remove_foreign_key name: :party_foreign_key
      #   end
      def remove_foreign_key(options)
        @base.remove_foreign_key(@table_name, options)
      end

      # Deprecated
      def references_with_foreign_keys(*args)
        options = args.extract_options!

        if fk_options = options.delete(:foreign_key)
          p ActiveSupport::Deprecation.send(:deprecation_message, caller,
            ":foreign_key in t.references is deprecated. " \
            "Use t.foreign_key instead")
        end

        references_without_foreign_keys(*(args.dup << options))
      end
    end
  end
end
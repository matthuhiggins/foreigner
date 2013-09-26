module Foreigner
  module ConnectionAdapters
    module SchemaStatements
      def self.included(base)
        base::AbstractAdapter.class_eval do
          include Foreigner::ConnectionAdapters::AbstractAdapter
        end
      end
    end

    module AbstractAdapter
      def create_table(table_name, *args, &block)
        definition = nil
        super do |td|
          definition = td # This is my trick to get the definition
          block.call(td) unless block.nil?
        end
        definition.foreign_keys.each do |to_table, options_list|
          options_list.each do |options|
            add_foreign_key(table_name, to_table, options)
          end
        end
      end

      def supports_foreign_keys?
        false
      end

      # Checks to see if a foreign key exists on a table for a given constraint.
      #
      #   # Check a foreign key exists
      #   foreign_key_exists?(:suppliers, :companies)
      #
      #   # Check a foreign key with a custom name exists
      #   foreign_key_exists?(:suppliers, name: "fk_company_id")
      #
      #   # Check a foreign key on a column
      #   foreign_key_exists?(:suppliers, column: "company_id")
      #
      def foreign_key_exists?(table_name, options)
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
      # ====== Creating a named foreign key
      #  add_foreign_key(:comments, :posts, name: 'comments_belongs_to_posts')
      # generates
      #  ALTER TABLE `comments` ADD CONSTRAINT
      #     `comments_belongs_to_posts` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`)
      #
      # ====== Creating a cascading foreign_key on a custom column
      #  add_foreign_key(:people, :people, column: 'best_friend_id', dependent: :nullify)
      # generates
      #  ALTER TABLE `people` ADD CONSTRAINT
      #     `people_best_friend_id_fk` FOREIGN KEY (`best_friend_id`) REFERENCES `people` (`id`)
      #     ON DELETE SET NULL
      #
      # === Supported options
      # [:column]
      #   Specify the column name on the from_table that references the to_table. By default this is guessed
      #   to be the singular name of the to_table with "_id" suffixed. So a to_table of :posts will use "post_id"
      #   as the default <tt>:column</tt>.
      # [:primary_key]
      #   Specify the column name on the to_table that is referenced by this foreign key. By default this is
      #   assumed to be "id".
      # [:name]
      #   Specify the name of the foreign key constraint. This defaults to use from_table and foreign key column.
      # [:dependent]
      #   If set to <tt>:delete</tt>, the associated records in from_table are deleted when records in to_table table are deleted.
      #   If set to <tt>:nullify</tt>, the foreign key column is set to +NULL+.
      # [:options]
      #   Any extra options you want appended to the foreign key definition.
      def add_foreign_key(from_table, to_table, options = {})
      end

      # Remove the given foreign key from the table.
      #
      # ===== Examples
      # ====== Remove the suppliers_company_id_fk in the suppliers table.
      #   remove_foreign_key :suppliers, :companies
      # ====== Remove the foreign key named accounts_branch_id_fk in the accounts table.
      #   remove_foreign_key :accounts, column: :branch_id
      # ====== Remove the foreign key named party_foreign_key in the accounts table.
      #   remove_foreign_key :accounts, name: :party_foreign_key
      def remove_foreign_key(from_table, options)
      end

      # Return the foreign keys for the schema_dumper
      def foreign_keys(table_name)
        []
      end
    end
  end
end

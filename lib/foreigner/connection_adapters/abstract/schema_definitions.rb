module Foreigner
  module ConnectionAdapters
    class ForeignKeyDefinition < Struct.new(:from_table, :to_table, :options) #:nodoc:
    end

    module SchemaDefinitions
      def self.included(base)
        base::TableDefinition.class_eval do
          include Foreigner::ConnectionAdapters::TableDefinition
        end
        
        base::Table.class_eval do
          include Foreigner::ConnectionAdapters::Table
        end
      end
    end
  
    module TableDefinition
      class ForeignKey < Struct.new(:base, :to_table, :options)
        def to_sql
          base.foreign_key_definition(to_table, options)
        end
        alias to_s :to_sql
      end

      def self.included(base)
        base.class_eval do
          include InstanceMethods
          alias_method_chain :references, :foreign_keys
          alias_method_chain :to_sql, :foreign_keys
        end
      end
    
      module InstanceMethods
        # Adds a :foreign_key option to TableDefinition.references.
        # If :foreign_key is true, a foreign key constraint is added to the table.
        # You can also specify a hash, which is passed as foreign key options.
        # 
        # ===== Examples
        # ====== Add goat_id column and a foreign key to the goats table.
        #  t.references(:goat, :foreign_key => true)
        # ====== Add goat_id column and a cascading foreign key to the goats table.
        #  t.references(:goat, :foreign_key => {:dependent => :delete})
        # 
        # Note: No foreign key is created if :polymorphic => true is used.
        # Note: If no name is specified, the database driver creates one for you!
        def references_with_foreign_keys(*args)
          options = args.extract_options!
          fk_options = options.delete(:foreign_key)

          if fk_options && !options[:polymorphic]
            fk_options = {} if fk_options == true
            args.each { |to_table| foreign_key(to_table, fk_options) }
          end

          references_without_foreign_keys(*(args << options))
        end
    
        # Defines a foreign key for the table. +to_table+ can be a single Symbol, or
        # an Array of Symbols. See SchemaStatements#add_foreign_key
        #
        # ===== Examples
        # ====== Creating a simple foreign key
        #  t.foreign_key(:people)
        # ====== Defining the column
        #  t.foreign_key(:people, :column => :sender_id)
        # ====== Creating a named foreign key
        #  t.foreign_key(:people, :column => :sender_id, :name => 'sender_foreign_key')
        # ====== Defining the column of the +to_table+.
        #  t.foreign_key(:people, :column => :sender_id, :primary_key => :person_id)
        def foreign_key(to_table, options = {})
          if @base.supports_foreign_keys?
            to_table = to_table.to_s.pluralize if ActiveRecord::Base.pluralize_table_names
            foreign_keys << ForeignKey.new(@base, to_table, options)
          end
        end
      
        def to_sql_with_foreign_keys
          sql = to_sql_without_foreign_keys
          sql << ', ' << (foreign_keys * ', ') if foreign_keys.present?
          sql
        end
      
        private
          def foreign_keys
            @foreign_keys ||= []
          end
      end
    end

    module Table
      def self.included(base)
        base.class_eval do
          include InstanceMethods
          alias_method_chain :references, :foreign_keys
        end
      end

      module InstanceMethods
        # Adds a new foreign key to the table. +to_table+ can be a single Symbol, or
        # an Array of Symbols. See SchemaStatements#add_foreign_key
        #
        # ===== Examples
        # ====== Creating a simple foreign key
        #  t.foreign_key(:people)
        # ====== Defining the column
        #  t.foreign_key(:people, :column => :sender_id)
        # ====== Creating a named foreign key
        #  t.foreign_key(:people, :column => :sender_id, :name => 'sender_foreign_key')
        # ====== Defining the column of the +to_table+.
        #  t.foreign_key(:people, :column => :sender_id, :primary_key => :person_id)
        def foreign_key(to_table, options = {})
          @base.add_foreign_key(@table_name, to_table, options)
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
      
        # Adds a :foreign_key option to TableDefinition.references.
        # If :foreign_key is true, a foreign key constraint is added to the table.
        # You can also specify a hash, which is passed as foreign key options.
        # 
        # ===== Examples
        # ====== Add goat_id column and a foreign key to the goats table.
        #  t.references(:goat, :foreign_key => true)
        # ====== Add goat_id column and a cascading foreign key to the goats table.
        #  t.references(:goat, :foreign_key => {:dependent => :delete})
        # 
        # Note: No foreign key is created if :polymorphic => true is used.
        def references_with_foreign_keys(*args)
          options = args.extract_options!
          polymorphic = options[:polymorphic]
          fk_options = options.delete(:foreign_key)

          references_without_foreign_keys(*(args << options))

          if fk_options && !polymorphic
            fk_options = {} if fk_options == true
            args.each { |to_table| foreign_key(to_table, fk_options) }
          end
        end
      end
    end
  end
end

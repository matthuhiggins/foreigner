module Foreigner
  module ConnectionAdapters
    module PostgreSQLAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      def remove_foreign_key(table, options)
        if Hash === options
          foreign_key_name = foreign_key_name(table, options[:column], options)
        else
          foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
        end

        execute "ALTER TABLE #{quote_table_name(table)} DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
      end
      
      def foreign_keys(table_name)
        fk_info = select_all %{
          SELECT tc.constraint_name as name
                ,ccu.table_name as to_table
                ,ccu.column_name as primary_key
                ,kcu.column_name as column
                ,rc.delete_rule as dependency
          FROM information_schema.table_constraints tc
          JOIN information_schema.key_column_usage kcu
          USING (constraint_catalog, constraint_schema, constraint_name)
          JOIN information_schema.referential_constraints rc
          USING (constraint_catalog, constraint_schema, constraint_name)
          JOIN information_schema.constraint_column_usage ccu
          USING (constraint_catalog, constraint_schema, constraint_name)
          WHERE tc.constraint_type = 'FOREIGN KEY'
            AND tc.constraint_catalog = '#{@config[:database]}'
            AND tc.table_name = '#{table_name}'
        }
        
        fk_info.map do |row|
          options = {:column => row['column'], :name => row['name'], :primary_key => row['primary_key']}

          if row['dependency'] == 'CASCADE'
            options[:dependent] = :delete
          elsif row['dependency'] == 'SET NULL'
            options[:dependent] = :nullify
          end
          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    PostgreSQLAdapter.class_eval do
      include Foreigner::ConnectionAdapters::PostgreSQLAdapter
    end
  end
end
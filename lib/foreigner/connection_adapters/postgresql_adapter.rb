module Foreigner
  module ConnectionAdapters
    module PostgreSQLAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      def foreign_keys(table_name)
        fk_info = select_all %{
          SELECT t2.relname AS to_table, a1.attname AS column, a2.attname AS primary_key, c.conname AS name, c.confdeltype AS dependency, c.confupdtype AS update_action
          FROM pg_constraint c
          JOIN pg_class t1 ON c.conrelid = t1.oid
          JOIN pg_class t2 ON c.confrelid = t2.oid
          JOIN pg_attribute a1 ON a1.attnum = c.conkey[1] AND a1.attrelid = t1.oid
          JOIN pg_attribute a2 ON a2.attnum = c.confkey[1] AND a2.attrelid = t2.oid
          JOIN pg_namespace t3 ON c.connamespace = t3.oid
          WHERE c.contype = 'f'
            AND t1.relname = '#{table_name}'
            AND t3.nspname = ANY (current_schemas(false))
          ORDER BY c.conname
        }
        
        fk_info.map do |row|
          options = {:column => row['column'], :name => row['name'], :primary_key => row['primary_key']}

          options[:dependent] = case row['dependency']
            when 'c' then :delete
            when 'n' then :nullify
            when 'r' then :restrict
          end

          options[:on_update] = case row['dependency']
            when 'c' then :cascade
            when 'r' then :restrict
            when 'n' then :set_null
            when 'd' then :set_default
            when 'a' then :none
          end

          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

[:PostgreSQLAdapter, :JdbcAdapter].each do |adapter|
  begin
    ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
      include Foreigner::ConnectionAdapters::PostgreSQLAdapter
    end
  rescue
  end
end
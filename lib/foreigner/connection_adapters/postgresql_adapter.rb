module Foreigner
  module ConnectionAdapters
    module PostgreSQLAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      DEPENDENCY_CODE_ACTIONS = {'c' => 'CASCADE', 'n' => 'SET NULL', 'r' => 'RESTRICT', 'd' => 'SET DEFAULT'}

      def foreign_keys(table_name)
        fk_info = select_all %{
          SELECT t2.relname AS to_table
               , a1.attname AS column
               , a2.attname AS primary_key
               , c.conname AS name
               , c.confdeltype AS dependency
               , c.confupdtype AS update_dependency
               , c.condeferrable AS deferrable
               , c.condeferred AS deferred
            #{", c.convalidated AS valid" if postgresql_version >= 90100}
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
          options = {column: row['column'], name: row['name'], primary_key: row['primary_key']}

          options[:dependent] = case row['dependency']
            # NO ACTION is the default
            # SET DEFAULT is handled below, since it is postgres-specific
            when 'c' then :delete
            when 'n' then :nullify
            when 'r' then :restrict
          end

          extras = []
          extras << "ON DELETE SET DEFAULT"      if row['dependency'] == 'd'
          if update_action = DEPENDENCY_CODE_ACTIONS[row['update_dependency']]
            extras << "ON UPDATE #{update_action}"
          end
          extras << 'DEFERRABLE'                 if row['deferrable'] == 't'
          extras << 'INITIALLY DEFERRED'         if row['deferred'] == 't'
          extras << 'NOT VALID'                  if row['valid'] == 'f'
          options[:options] = extras.join(" ")

          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

Foreigner::Adapter.safe_include :JdbcAdapter, Foreigner::ConnectionAdapters::PostgreSQLAdapter
Foreigner::Adapter.safe_include :PostgreSQLAdapter, Foreigner::ConnectionAdapters::PostgreSQLAdapter

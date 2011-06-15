module Foreigner
  module ConnectionAdapters
    module Mysql2Adapter
      include Foreigner::ConnectionAdapters::Sql2003

      def drop_table(table_name, options = {})
        execute "SET FOREIGN_KEY_CHECKS=0"
        execute "DROP TABLE #{quote_table_name(table_name)}"
        execute "SET FOREIGN_KEY_CHECKS=1"
      end
      
      def remove_foreign_key_sql(table, options)
        if Hash === options
          foreign_key_name = foreign_key_name(table, options[:column], options)
        else
          foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
        end

        "DROP FOREIGN KEY #{quote_column_name(foreign_key_name)}"
      end
      
      def foreign_keys(table_name)
        fk_info = select_all %{
          SELECT fk.referenced_table_name as 'to_table'
                ,fk.referenced_column_name as 'primary_key'
                ,fk.column_name as 'column'
                ,fk.constraint_name as 'name'
          FROM information_schema.key_column_usage fk
          WHERE fk.referenced_column_name is not null
            AND fk.table_schema = '#{@config[:database]}'
            AND fk.table_name = '#{table_name}'
        }

        create_table_info = select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]

        fk_info.map do |row|
          options = {:column => row['column'], :name => row['name'], :primary_key => row['primary_key']}

          if create_table_info =~ /CONSTRAINT #{quote_column_name(row['name'])} FOREIGN KEY .* REFERENCES .* ON DELETE (CASCADE|SET NULL|RESTRICT)/
            options[:dependent] = case $1
              when 'CASCADE'  then :delete
              when 'SET NULL' then :nullify
              when 'RESTRICT' then :restrict
            end
          end
          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

[:Mysql2Adapter, :JdbcAdapter].each do |adapter|
  begin
    ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
      include Foreigner::ConnectionAdapters::Mysql2Adapter
    end
  rescue
  end
end
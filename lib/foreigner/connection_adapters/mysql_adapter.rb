module Foreigner
  module ConnectionAdapters
    module MysqlAdapter
      include Foreigner::ConnectionAdapters::Sql2003
      
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

          if create_table_info =~ /CONSTRAINT #{quote_column_name(row['name'])} FOREIGN KEY .* REFERENCES .* ON DELETE (CASCADE|SET NULL)/
            if $1 == 'CASCADE'
              options[:dependent] = :delete
            elsif $1 == 'SET NULL'
              options[:dependent] = :nullify
            end
          end
          ForeignKeyDefinition.new(table_name, row['to_table'], options)
        end
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    MysqlAdapter.class_eval do
      include Foreigner::ConnectionAdapters::MysqlAdapter
    end
  end
end

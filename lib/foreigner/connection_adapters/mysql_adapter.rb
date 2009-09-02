module Foreigner
  module MysqlAdapter
    def supports_foreign_keys?
      true
    end
    
    def add_foreign_key(from_table, to_table, options = {})
      column  = options[:column] || "#{to_table.to_s.singularize}_id"
      foreign_key_name = foreign_key_name(from_table, column, options)

      sql =
        "ALTER TABLE #{quote_table_name(from_table)} " +
        "ADD CONSTRAINT #{quote_column_name(foreign_key_name)} " +
        foreign_key_definition(to_table, options)
      
      execute(sql)
    end
    
    def foreign_key_definition(to_table, options = {})
      column  = options[:column] || "#{to_table.to_s.singularize}_id"
      dependency = dependency_sql(options[:dependent])

      sql = "FOREIGN KEY (#{quote_column_name(column)}) REFERENCES #{quote_table_name(to_table)}(id)"
      sql << " #{dependency}" unless dependency.blank?
      sql
    end

    def remove_foreign_key(table, options)
      if Hash === options
        foreign_key_name = foreign_key_name(table, options[:column], options)
      else
        foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
      end

      execute "ALTER TABLE #{quote_table_name(table)} DROP FOREIGN KEY #{quote_column_name(foreign_key_name)}"
    end
    
    def foreign_keys(table_name)
      foreign_keys = []
      fk_info = select_all %{
        SELECT fk.referenced_table_name as 'to_table'
              ,fk.column_name as 'column'
              ,fk.constraint_name as 'name'
        FROM information_schema.key_column_usage fk
        WHERE fk.referenced_column_name is not null
          AND fk.table_schema = '#{@config[:database]}'
          AND fk.table_name = '#{table_name}'
      }

      create_table_info = select_one("SHOW CREATE TABLE #{quote_table_name(table_name)}")["Create Table"]

      fk_info.each do |row|
        options = {:column => row['column'], :name => row['name']}
        if create_table_info =~ /CONSTRAINT #{quote_column_name(row['name'])} FOREIGN KEY .* REFERENCES .* ON DELETE (CASCADE|SET NULL)/
          if $1 == 'CASCADE'
            options[:dependent] = :delete
          elsif $1 == 'SET NULL'
            options[:dependent] = :nullify
          end
        end
        foreign_keys << ForeignKeyDefinition.new(table_name, row['to_table'], options)
      end
      
      foreign_keys
    end

    private
      def foreign_key_name(table, column, options = {})
        if options[:name]
          options[:name]
        else
          "#{table}_#{column}_fk"
        end
      end

      def dependency_sql(dependency)
        case dependency
          when :nullify then "ON DELETE SET NULL"
          when :delete  then "ON DELETE CASCADE"
          else ""
        end
      end
  end
end

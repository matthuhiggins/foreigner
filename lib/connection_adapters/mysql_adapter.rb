module Foreigner
  module MysqlAdapter
    def supports_foreign_keys?
      true
    end
    
    def add_foreign_key(from_table, to_table, options = {})
      column  = options[:column] || "#{to_table.to_s.singularize}_id"
      dependency = dependency_sql(options[:dependent])
      
      execute %{
        ALTER TABLE #{from_table}
        ADD CONSTRAINT #{foreign_key_name(from_table, column, options)}
        FOREIGN KEY (#{column}) REFERENCES #{to_table}(id)
        #{dependency}
      }
    end

    def remove_foreign_key(table, options)        
      if Hash === options
        foreign_key_name = foreign_key_name(table, options[:column], options)
      else
        foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
      end

      execute "ALTER TABLE #{table} DROP FOREIGN KEY #{foreign_key_name}"
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

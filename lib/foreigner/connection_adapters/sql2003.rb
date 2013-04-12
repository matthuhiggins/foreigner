module Foreigner
  module ConnectionAdapters
    module Sql2003
      def supports_foreign_keys?
        true
      end

      def drop_table(*args)
        options = args.extract_options!
        if options[:force]
          disable_referential_integrity { super }
        else
          super
        end
      end

      def add_foreign_key(from_table, to_table, options = {})
        sql = "ALTER TABLE #{quote_table_name(from_table)} #{add_foreign_key_sql(from_table, to_table, options)}"
        execute(sql)
      end

      def add_foreign_key_sql(from_table, to_table, options = {})
        column  = options[:column] || "#{to_table.to_s.singularize}_id"
        foreign_key_name = foreign_key_name(from_table, column, options)
        primary_key = options[:primary_key] || "id"
        dependency = dependency_sql(options[:dependent])
        on_update = on_update_action_sql(options[:on_update])

        sql =
          "ADD CONSTRAINT #{quote_column_name(foreign_key_name)} " +
          "FOREIGN KEY (#{quote_column_name(column)}) " +
          "REFERENCES #{quote_table_name(ActiveRecord::Migrator.proper_table_name(to_table))}(#{primary_key})"
        sql << " #{on_update}" if on_update.present?
        sql << " #{dependency}" if dependency.present?
        sql << " #{options[:options]}" if options[:options]

        sql
      end

      def remove_foreign_key(table, options)
        execute "ALTER TABLE #{quote_table_name(table)} #{remove_foreign_key_sql(table, options)}"
      end

      def remove_foreign_key_sql(table, options)
        if Hash === options
          foreign_key_name = foreign_key_name(table, options[:column], options)
        else
          foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
        end

        "DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
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
            when :restrict then "ON DELETE RESTRICT"
            else ""
          end
        end

        def on_update_action_sql(update_action)
          case update_action
            when :none        then 'ON UPDATE NO ACTION'    # PgSQL, MySQL
            when :restrict    then 'ON UPDATE RESTRICT'     # PgSQL, MySQL
            when :cascade     then 'ON UPDATE CASCADE'      # PgSQL, MySQL
            when :set_null    then 'ON UPDATE SET NULL'     # PgSQL, MySQL
            when :set_default then 'ON UPDATE SET DEFAULT'  # PgSQL
            else ''
          end
        end
    end
  end
end
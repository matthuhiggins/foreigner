module Foreigner
  module ConnectionAdapters
    module Sql2003
      def supports_foreign_keys?
        true
      end

      def drop_table(*args)
        options = args.extract_options!
        if options[:force]
          disable_referential_integrity { super(*(args.dup << options)) }
        else
          super(*(args.dup << options))
        end
      end

      def foreign_key_exists?(from_table, options)
        foreign_key_name = decipher_foreign_key_name(from_table, options)
        foreign_keys(from_table).any? { |fk| fk.name == foreign_key_name }
      end

      def add_foreign_key(from_table, to_table, options = {})
        unless skip_add_foreign_key?(from_table, options)
          sql = "ALTER TABLE #{quote_proper_table_name(from_table)} #{add_foreign_key_sql(from_table, to_table, options)}"
          execute(sql)
        end
      end

      # Retain original functionality -- do not skip add_foreign_key if Apartment is not even present
      # Apartment functionality:
      #  - Skip add_foreign_key if schema name is specified, equal to 'public' schema, and foreign_key already exists
      def skip_add_foreign_key?(from_table, options)
        return false unless Object.const_defined?(:Apartment)

        _table_name, schema_name, _namespace_name = get_db_object_names(from_table)
        schema_name && schema_name == Apartment.default_schema && foreign_key_exists?(from_table, options)
      end

      def schema_specified?(table_name)
        table_name.is_a?(String) && table_name.include?('.')
      end

      # Returns table_name, schema_name and namespace_name
      #
      # get_db_object_names('schema_name.table_name') => ['table_name', 'schema_name', "'schema_name'"]
      # get_db_object_names('table_name')             => ['table_name', nil, ANY (current_schemas(false))']
      def get_db_object_names(full_name)
        if schema_specified?(full_name)
          schema_name, table_name = full_name.split('.')
          [table_name, schema_name, "'#{schema_name}'"]
        else
          [full_name, nil, 'ANY (current_schemas(false))']
        end
      end

      def add_foreign_key_sql(from_table, to_table, options = {})
        column  = options[:column] || "#{to_table.to_s.singularize}_id"
        foreign_key_name = options.key?(:name) ? options[:name].to_s : foreign_key_name(from_table, column)
        primary_key = options[:primary_key] || "id"
        dependency = dependency_sql(options[:dependent])

        sql =
          "ADD CONSTRAINT #{quote_column_name(foreign_key_name)} " +
          "FOREIGN KEY (#{quote_column_name(column)}) " +
          "REFERENCES #{quote_proper_table_name(to_table)}(#{primary_key})"
        sql << " #{dependency}" if dependency.present?
        sql << " #{options[:options]}" if options[:options]

        sql
      end

      def quote_proper_table_name(table)
        quote_table_name(proper_table_name(table))
      end

      def proper_table_name(table)
        # This will normally be a no-op, but prevents the table from being wrapped twice:
        table = Foreigner::SchemaDumper::ClassMethods.remove_prefix_and_suffix(table)
        if ActiveRecord::Migration.instance_methods(false).include? :proper_table_name
          ActiveRecord::Migration.new.proper_table_name(table, options = {
            table_name_prefix: ActiveRecord::Base.table_name_prefix,
            table_name_suffix: ActiveRecord::Base.table_name_suffix
          })
        else
          ActiveRecord::Migrator.proper_table_name(table)
        end
      end

      def remove_foreign_key(table, options)
        execute "ALTER TABLE #{quote_proper_table_name(table)} #{remove_foreign_key_sql(table, options)}"
      end

      def remove_foreign_key_sql(table, options)
        foreign_key_name = decipher_foreign_key_name(table, options)
        "DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
      end

      private
        def foreign_key_name(table_name, column_with_schema_name)
          column, _schema_name, _namespace_name = get_db_object_names(column_with_schema_name)
          "#{table_name}_#{column}_fk"
        end

        def foreign_key_column(to_table)
          "#{to_table.to_s.singularize}_id"
        end

        def decipher_foreign_key_name(from_table, options)
          if Hash === options
            options.key?(:name) ? options[:name].to_s : foreign_key_name(from_table, options[:column])
          else
            foreign_key_name(from_table, foreign_key_column(options))
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
    end
  end
end

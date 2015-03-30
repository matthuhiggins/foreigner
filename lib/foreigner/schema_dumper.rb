module Foreigner
  module SchemaDumper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :tables, :foreign_keys
    end

    module ClassMethods
      def dump_foreign_key(foreign_key)
        statement_parts = [ ('add_foreign_key ' + remove_prefix_and_suffix(foreign_key.from_table).inspect) ]
        statement_parts << remove_prefix_and_suffix(foreign_key.to_table).inspect
        statement_parts << ('name: ' + foreign_key.options[:name].inspect)

        if foreign_key.options[:column] != "#{remove_prefix_and_suffix(foreign_key.to_table).singularize}_id"
          statement_parts << ('column: ' + foreign_key.options[:column].inspect)
        end
        if foreign_key.options[:primary_key] != 'id'
          statement_parts << ('primary_key: ' + foreign_key.options[:primary_key].inspect)
        end
        if foreign_key.options[:dependent].present?
          statement_parts << ('dependent: ' + foreign_key.options[:dependent].inspect)
        end
        if foreign_key.options[:options].present?
          statement_parts << ('options: ' + foreign_key.options[:options].inspect)
        end

        statement_parts.join(', ')
      end

      def remove_prefix_and_suffix(table_name)
        table_name = table_name.to_s
        pre, suff = ActiveRecord::Base.table_name_prefix, ActiveRecord::Base.table_name_suffix
        if table_name.start_with?(pre) && table_name.end_with?(suff)
          table_name[pre.size..-(suff.size + 1)]
        else
          table_name
        end
      end
      module_function :remove_prefix_and_suffix
    end

    def requires_foreigner_load?
      major, minor, patch = Foreigner::Helper.active_record_version.segments
      major == 4 && minor == 1 && patch >= 9
    end

    def tables_with_foreign_keys(stream)
      tables_without_foreign_keys(stream)
      # Ensure Foreigner to be initialized before running foreign_keys.
      # This is required since schema::load is not initializing the environment
      # anymore in Rails 4.1.9 (https://github.com/rails/rails/commit/5d6bb89f)
      stream.puts '  Foreigner.load' if requires_foreigner_load?
      @connection.tables.sort.each do |table|
        next if ['schema_migrations', ignore_tables].flatten.any? do |ignored|
          case ignored
          when String; table == ignored
          when Regexp; table =~ ignored
          else
            raise StandardError, 'ActiveRecord::SchemaDumper.ignore_tables accepts an array of String and / or Regexp values.'
          end
        end
        foreign_keys(table, stream)
      end
    end

    private
      def foreign_keys(table_name, stream)
        if (foreign_keys = @connection.foreign_keys(table_name)).any?
          add_foreign_key_statements = foreign_keys.map do |foreign_key|
            '  ' + self.class.dump_foreign_key(foreign_key)
          end

          stream.puts add_foreign_key_statements.sort.join("\n")
          stream.puts
        end
      end
  end
end

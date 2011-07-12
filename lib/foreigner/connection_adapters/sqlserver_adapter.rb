module Foreigner
  module ConnectionAdapters
    module SQLServerAdapter
      include Foreigner::ConnectionAdapters::Sql2003

      def remove_foreign_key(table, options)
        if Hash === options
          foreign_key_name = foreign_key_name(table, options[:column], options)
        else
          foreign_key_name = foreign_key_name(table, "#{options.to_s.singularize}_id")
        end

        execute "ALTER TABLE #{quote_table_name(table)} DROP CONSTRAINT #{quote_column_name(foreign_key_name)}"
      end

    end
  end
end

[:SQLServerAdapter, :JdbcAdapter].each do |adapter|
  begin
    ActiveRecord::ConnectionAdapters.const_get(adapter).class_eval do
      include Foreigner::ConnectionAdapters::SQLServerAdapter
    end
  rescue
  end
end
module Foreigner
  module SchemaDumper
    extend ActiveSupport::Concern

    included do
      alias_method_chain :tables, :foreign_keys
    end
    
    def tables_with_foreign_keys(stream)
      tables_without_foreign_keys(stream)
      @connection.tables.sort.each do |table|
        foreign_keys(table, stream)
      end
    end
    
    private
      def foreign_keys(table_name, stream)
        if (foreign_keys = @connection.foreign_keys(table_name)).any?
          add_foreign_key_statements = foreign_keys.map do |foreign_key|
            '  ' + Foreigner::Migration::Generator.add_foreign_key_statement(foreign_key)
          end

          stream.puts add_foreign_key_statements.sort.join("\n")
          stream.puts
        end
      end
  end
end
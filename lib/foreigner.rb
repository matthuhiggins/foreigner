require 'connection_adapters/abstract/schema_statements'
require 'connection_adapters/abstract/schema_definitions'
require 'connection_adapters/mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    AbstractAdapter.class_eval do
      include Foreigner::AdapterMethods
    end
    
    MysqlAdapter.class_eval do
      include Foreigner::MysqlAdapter
    end

    TableDefinition.class_eval do
      include Foreigner::TableDefinition

      Table.class_eval do
        include Foreigner::Table
      end
    end
  end
end
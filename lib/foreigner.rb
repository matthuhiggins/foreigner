require 'connection_adapters/abstract/schema_definitions'
require 'connection_adapters/abstract/schema_statements'
require 'connection_adapters/mysql_adapter'

module ActiveRecord
  module ConnectionAdapters
    AbstractAdapter.class_eval do
      include Foreigner::AdapterMethods
    end
    
    MysqlAdapter.class_eval do
      include Foreigner::MysqlAdapter
    end

    class TableDefinition
      Table.class_eval do
        include Foreigner::TableMethods
      end
    end
  end
end
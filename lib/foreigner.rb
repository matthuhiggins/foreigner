require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/connection_adapters/mysql_adapter'
require 'foreigner/schema_dumper'

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
    end

    Table.class_eval do
      include Foreigner::Table
    end
  end
  
  SchemaDumper.class_eval do
    include Foreigner::SchemaDumper
  end
end
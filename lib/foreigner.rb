require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/schema_dumper'

module ActiveRecord
  module ConnectionAdapters
    AbstractAdapter.class_eval do
      include Foreigner::AdapterMethods
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
  
  Base.class_eval do
    if ['MySQL', 'PostgreSQL'].include? connection.adapter_name
      require "foreigner/connection_adapters/#{connection.adapter_name.downcase}_adapter"
    end
  end
end
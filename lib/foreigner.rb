require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/connection_adapters/sql_2003'
require 'foreigner/schema_dumper'

module ActiveRecord
  module ConnectionAdapters
    include Foreigner::ConnectionAdapters::SchemaStatements
    include Foreigner::ConnectionAdapters::SchemaDefinitions
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
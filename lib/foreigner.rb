require 'foreigner/connection_adapters/abstract/schema_statements'
require 'foreigner/connection_adapters/abstract/schema_definitions'
require 'foreigner/connection_adapters/sql_2003'
require 'foreigner/schema_dumper'

module Foreigner
  mattr_accessor :adapters
  self.adapters = {}

  class << self
    def register(adapter_name, file_name)
      adapters[adapter_name] = file_name
    end
  
    def load_adapter!(adapter_name)
      if adapters.key?(adapter_name)
        require adapters[adapter_name]
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    include Foreigner::ConnectionAdapters::SchemaStatements
    include Foreigner::ConnectionAdapters::SchemaDefinitions
  end
  
  SchemaDumper.class_eval do
    include Foreigner::SchemaDumper
  end
end

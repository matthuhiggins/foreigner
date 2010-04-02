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
  
    def load_adapter!
      if adapters.key?(configured_adapter)
        require adapters[configured_adapter]
      end
    end
    
    def configured_adapter
      ActiveRecord::Base.connection_pool.spec.config[:adapter].downcase
    end
    
    def on_load(&block)
      if Rails.version >= '3.0'
        ActiveSupport.on_load(:active_record, &block)
      else
        yield
      end
    end
  end
end

Foreigner.on_load do
  module ActiveRecord
    module ConnectionAdapters
      include Foreigner::ConnectionAdapters::SchemaStatements
      include Foreigner::ConnectionAdapters::SchemaDefinitions
    end

    SchemaDumper.class_eval do
      include Foreigner::SchemaDumper
    end
  end
end
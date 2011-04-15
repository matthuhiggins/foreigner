module Foreigner
  extend ActiveSupport::Autoload
  autoload :SchemaDumper

  module ConnectionAdapters
    extend ActiveSupport::Autoload
    autoload :Sql2003

    autoload_under 'abstract' do
      autoload :SchemaStatements
      autoload :SchemaDefinitions
    end
  end
  
  class << self
    def adapters
      @@adapters ||= {}
    end

    def register(adapter_name, file_name)
      adapters[adapter_name] = file_name
    end

    def load_adapter!
      ActiveRecord::ConnectionAdapters.module_eval do
        include Foreigner::ConnectionAdapters::SchemaStatements
        include Foreigner::ConnectionAdapters::SchemaDefinitions
      end

      ActiveRecord::SchemaDumper.class_eval do
        include Foreigner::SchemaDumper
      end

      if adapters.key?(configured_adapter)
        require adapters[configured_adapter]
      end
    end

    def configured_adapter
      ActiveRecord::Base.connection_pool.spec.config[:adapter]
    end
  end
end

Foreigner.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'mysql2', 'foreigner/connection_adapters/mysql_adapter'
Foreigner.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'

require 'foreigner/railtie'
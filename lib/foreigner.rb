require 'active_support/all'

module Foreigner
  extend ActiveSupport::Autoload
  autoload :Adapter
  autoload :SchemaDumper

  module ConnectionAdapters
    extend ActiveSupport::Autoload
    autoload :Sql2003

    autoload_under 'abstract' do
      autoload :SchemaDefinitions
      autoload :SchemaStatements
    end
  end

  module Migration
    autoload :CommandRecorder, 'foreigner/migration/command_recorder'
    autoload :Generator, 'foreigner/migration/generator'
  end
end

Foreigner::Adapter.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner::Adapter.register 'mysql2', 'foreigner/connection_adapters/mysql2_adapter'
Foreigner::Adapter.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'

require 'foreigner/railtie' if defined?(Rails)

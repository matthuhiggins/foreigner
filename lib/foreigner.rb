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
  end

  def self.load_adapter
    ActiveSupport.on_load :active_record do
      ActiveRecord::ConnectionAdapters.module_eval do
        include Foreigner::ConnectionAdapters::SchemaStatements
        include Foreigner::ConnectionAdapters::SchemaDefinitions
      end

      ActiveRecord::SchemaDumper.class_eval do
        include Foreigner::SchemaDumper
      end

      if defined?(ActiveRecord::Migration::CommandRecorder)
        ActiveRecord::Migration::CommandRecorder.class_eval do
          include Foreigner::Migration::CommandRecorder
        end
      end

      Foreigner::Adapter.load!
    end
  end
end

Foreigner::Adapter.register 'mysql', 'foreigner/connection_adapters/mysql_adapter'
Foreigner::Adapter.register 'mysql2', 'foreigner/connection_adapters/mysql2_adapter'
Foreigner::Adapter.register 'jdbcmysql', 'foreigner/connection_adapters/mysql2_adapter'
Foreigner::Adapter.register 'postgresql', 'foreigner/connection_adapters/postgresql_adapter'

if defined?(Rails)
  require 'foreigner/railtie' 
elsif defined?(Padrino)
  Padrino.after_load {
    Foreigner.load_adapter
  }
end

module Foreigner
  class Railtie < Rails::Railtie
    initializer 'foreigner.load_adapter' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::ConnectionAdapters.module_eval do
          include Foreigner::ConnectionAdapters::SchemaStatements
          include Foreigner::ConnectionAdapters::SchemaDefinitions
        end

        ActiveRecord::SchemaDumper.class_eval do
          include Foreigner::SchemaDumper
        end

        Foreigner::Adapter.load!
      end
    end
  end
end
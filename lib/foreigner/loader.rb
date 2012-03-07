module Foreigner
  def self.load
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
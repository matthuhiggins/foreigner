module Foreigner
  module ConnectionAdapters    
    module SchemaDefinitions
      def self.included(base)
        base::Table.class_eval do
          include Foreigner::ConnectionAdapters::Table
        end

        base::TableDefinition.class_eval do
          include Foreigner::ConnectionAdapters::TableDefinition
        end
      end
    end
  end
end

module Foreigner
  module ConnectionAdapters
    class ForeignKeyDefinition < Struct.new(:from_table, :to_table, :options) #:nodoc:
      def name
        options[:name]
      end
    end
  end
end
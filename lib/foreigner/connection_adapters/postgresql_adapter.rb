require 'foreigner/connection_adapters/sql_2003'

module Foreigner
  module ConnectionAdapters
    module PostgreSQLAdapter
      include Foreigner::ConnectionAdapters::Sql2003
      
      def foreign_keys(table_name)
        
      end
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    PostgreSQLAdapter.class_eval do
      include Foreigner::ConnectionAdapters::PostgreSQLAdapter
    end
  end
end
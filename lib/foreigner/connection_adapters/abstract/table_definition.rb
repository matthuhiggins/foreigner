module Foreigner
  module ConnectionAdapters    
    module TableDefinition
      def foreign_key(to_table, options = {})
        foreign_keys[to_table] ||= []
        foreign_keys[to_table] << options
      end

      def foreign_keys
        @foreign_keys ||= {}
      end
    end
  end
end
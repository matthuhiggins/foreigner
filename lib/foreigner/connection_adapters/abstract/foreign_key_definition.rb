module Foreigner
  module ConnectionAdapters
    class ForeignKeyDefinition < Struct.new(:from_table, :to_table, :options) #:nodoc:
    end
  end
end
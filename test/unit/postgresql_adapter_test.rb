require 'helper'
require 'foreigner/connection_adapters/postgresql_adapter'

class Foreigner::PostgreSQLAdapterTest < Foreigner::UnitTest
  include Foreigner::ConnectionAdapters::PostgreSQLAdapter
end
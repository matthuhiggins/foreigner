require 'helper'

class Foreigner::ConnectionAdapters::TableDefinitionsTest < ActiveSupport::TestCase
  class TestDefinition
    include Foreigner::ConnectionAdapters::TableDefinition
  end

  test "foreign_key" do
    definition = TestDefinition.new
    definition.foreign_key :poops, and: :one;
    assert_equal definition.foreign_keys[:poops], and: :one
  end
end
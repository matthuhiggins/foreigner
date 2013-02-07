require 'helper'

class Foreigner::ConnectionAdapters::TableDefinitionsTest < ActiveSupport::TestCase
  class TestDefinition
    include Foreigner::ConnectionAdapters::TableDefinition
  end

  test "foreign_key used once" do
    definition = TestDefinition.new
    definition.foreign_key :poops, and: :one;
    assert_equal [{ and: :one }], definition.foreign_keys[:poops]
  end

  test "foreign_key used twice" do
    definition = TestDefinition.new
    definition.foreign_key :nodes, column: :from_id
    definition.foreign_key :nodes, column: :to_id
    assert_equal [{ column: :from_id }, { column: :to_id }],
      definition.foreign_keys[:nodes]
  end
end
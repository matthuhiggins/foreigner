require File.dirname(__FILE__) + '/test_helper'

class ForeignerTest < ActiveRecord::TestCase
  def setup
    ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
      alias_method :execute_without_stub, :execute
      def execute(sql, name = nil) return sql end
    end
  end

  def teardown
    ActiveRecord::ConnectionAdapters::MysqlAdapter.class_eval do
      remove_method :execute
      alias_method :execute, :execute_without_stub
    end
  end
  
  
end
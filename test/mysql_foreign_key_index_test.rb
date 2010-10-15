require 'rubygems'
require 'yaml'
require 'test/unit'
require 'active_record'

config = YAML.load_file(File.dirname(__FILE__) + '/databases.yml')
ActiveRecord::Base.establish_connection(config['mysql'])

# Avoid connection.index_exists? availability/signature differences
ActiveRecord::Base.connection.instance_eval do
  def has_index?(table, index)
    sql =<<-Q
      select index_name
        from information_schema.statistics
        where table_name = '#{table}'
          and index_name = '#{index}'
    Q
    !select_value(sql).nil?
  end
end

require 'foreigner'

class MySqlForeignKeyIndexTest < Test::Unit::TestCase
  def setup
    @fk_index = 'children_parent_id_fk'
    @connection = ActiveRecord::Base.connection
    create_tables
  end

  def test_add_foreign_key_adds_the_foriegn_key_index
    assert !@connection.has_index?(:children, @fk_index)
    @connection.add_foreign_key :children, :parents
    assert @connection.has_index?(:children, @fk_index)
  end

  def test_remove_foreign_key_removes_the_foriegn_key_index
    @connection.add_foreign_key :children, :parents
    assert @connection.has_index?(:children, @fk_index)
    @connection.remove_foreign_key :children, :parents
    assert !@connection.has_index?(:children, @fk_index)
  end

  def test_keep_foreign_key_option_removes_the_key_but_keeps_its_index
    @connection.add_foreign_key :children, :parents
    @connection.remove_foreign_key :children, :column => :parent_id, :keep_index => true
    assert @connection.has_index?(:children, @fk_index)
  end
  
  private
  def create_tables
    ActiveRecord::Schema.define do
      create_table 'children', :force => true do |t|
        t.references :parent
      end

      create_table 'parents', :force => true
    end
  end
end


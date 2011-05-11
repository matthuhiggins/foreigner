require 'helper'

Foreigner::ConnectionAdapters::SchemaDefinitions

class MockModel < ActiveRecord::Base
  self.abstract_class = true
  class << self
    def connection
      @connection ||= MockConnection.new
    end
  end
end

class MockConnection
  def supports_primary_key?; true; end
  def primary_key(table); table != 'authors_fans'; end
end

class GeneratorTest < Foreigner::AdapterTest
  def teardown
    ["Author", "Book", "AuthorsFan", "Fan", "Article", "Company", "Employee", "Manager"].each do |klass|
      GeneratorTest.send(:remove_const, klass) if GeneratorTest.const_defined?(klass)
    end
  end


  # basic scenarios
  
  test 'belongs_to should generate a foreign key' do
    class Author < MockModel; end
    class Book < MockModel
      belongs_to :author
    end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Book]).first
    )
  end

  test 'has_one should generate a foreign key' do
    class Author < MockModel
      has_one :book, :order => "id DESC"
    end
    class Book < MockModel; end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Book]).first
    )
  end

  test 'has_many should generate a foreign key' do
    class Author < MockModel
      has_many :books
    end
    class Book < MockModel; end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Book]).first
    )
  end

  test 'has_and_belongs_to_many should generate two foreign keys' do
    class Author < MockModel
      has_and_belongs_to_many :fans
    end
    class Fan < MockModel; end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'authors_fans', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       ),
       Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'authors_fans', 'fans', :column => 'fan_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Fan]).first
    )
  end


  # (no) duplication
  
  test 'STI should not generate duplicate foreign keys' do
    class Company < MockModel; end
    class Employee < MockModel
      belongs_to :company
    end
    class Manager < Employee; end

    assert(Manager.reflections.present?)
    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'employees', 'companies', :column => 'company_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Company, Employee, Manager]).first
    )
  end

  test 'complementary associations should not generate duplicate foreign keys' do
    class Author < MockModel
      has_many :books
    end
    class Book < MockModel
      belongs_to :author
    end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Book]).first
    )
  end

  test 'redundant associations should not generate duplicate foreign keys' do
    class Author < MockModel
      has_many :books
      has_many :favorite_books, :class_name => 'Book', :conditions => "awesome"
      has_many :bad_books, :class_name => 'Book', :conditions => "amateur_hour"
    end
    class Book < MockModel; end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Book]).first
    )
  end

  test 'conditional has_one/has_many associations should ignore :dependent' do
    class Author < MockModel
      has_many :articles, :conditions => "published", :dependent => :delete_all
      has_one :favorite_book, :class_name => 'Book', :conditions => "most_awesome", :dependent => :delete
    end
    class Book < MockModel; end
    class Article < MockModel; end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'articles', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       ),
       Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Article, Author, Book]).first
    )
  end


  # skipped associations

  test 'associations should not generate foreign keys if they already exist, even if :dependent/name are different' do
    database_keys = [
      Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
        'articles', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil, :name => "doesn't_matter"
      ),
      Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
        'books', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => :delete
      )
    ]

    class Author < MockModel
      has_many :articles
      has_one :favorite_book, :class_name => 'Book', :conditions => "most_awesome"
    end
    class Book < MockModel; end
    class Article < MockModel; end

    assert_equal(
      [],
      Foreigner::Migration::Generator.new_model_keys(database_keys, [Article, Author, Book]).first
    )
  end

  test 'finder_sql associations should not generate foreign keys' do
    class Author < MockModel
      has_many :books, :finder_sql => 'SELECT * FROM books WHERE author_id = #{id} ORDER BY RANDOM() LIMIT 5'
    end
    class Book < MockModel; end

    assert_equal(
      [],
      Foreigner::Migration::Generator.new_model_keys([], [Author, Book]).first
    )
  end

  test 'polymorphic associations should not generate foreign keys' do
    class Property < MockModel
      belongs_to :owner, :polymorphic => true 
    end
    class Person < MockModel
      has_many :properties, :as => :owner
    end
    class Corporation < MockModel
      has_many :properties, :as => :owner
    end

    assert_equal(
      [],
      Foreigner::Migration::Generator.new_model_keys([], [Corporation, Person, Property]).first
    )
  end

  test 'has_many :through should not generate foreign keys' do
    class Author < MockModel
      has_many :authors_fans
      has_many :fans, :through => :authors_fans
    end
    class AuthorsFan < MockModel
      belongs_to :author
      belongs_to :fan
    end
    class Fan < MockModel
      has_many :authors_fans
      has_many :authors, :through => :authors_fans
    end

    assert_equal(
      [Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'authors_fans', 'authors', :column => 'author_id', :primary_key => 'id', :dependent => nil
       ),
       Foreigner::ConnectionAdapters::ForeignKeyDefinition.new(
         'authors_fans', 'fans', :column => 'fan_id', :primary_key => 'id', :dependent => nil
       )],
      Foreigner::Migration::Generator.new_model_keys([], [Author, AuthorsFan, Fan]).first
    )
  end
end

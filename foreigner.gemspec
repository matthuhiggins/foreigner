# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'matthuhiggins-foreigner'
  s.version = '0.6.1'
  s.summary = 'Foreign keys for Rails'
  s.description = 'Adds helpers to migrations and correctly dumps foreign keys to schema.rb'
  
  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Matthew Higgins'
  s.email             = 'developer@matthewhiggins.com'
  s.homepage          = 'http://github.com/matthuhiggins/foreigner'
  s.rubyforge_project = 'matthuhiggins-foreigner'
  
  s.extra_rdoc_files = ["README"]
  s.files = %w(
    MIT-LICENSE
    Rakefile
    README
    lib/foreigner.rb
    lib/foreigner
    lib/foreigner/schema_dumper.rb
    lib/foreigner/connection_adapters
    lib/foreigner/connection_adapters/sql_2003.rb
    lib/foreigner/connection_adapters/mysql_adapter.rb
    lib/foreigner/connection_adapters/postgresql_adapter.rb
    lib/foreigner/connection_adapters/abstract/schema_definitions.rb
    lib/foreigner/connection_adapters/abstract/schema_statements.rb
    test/helper.rb
    test/mysql_adapter_test.rb
  )
  s.require_paths = %w(lib)  
end
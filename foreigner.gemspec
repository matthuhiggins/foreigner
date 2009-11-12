# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{matthuhiggins-foreigner}
  s.version = "0.3.1"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Higgins"]
  s.date = %q{2009-09-07}
  s.email = %q{developer@matthewhiggins.com}
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
  s.homepage = "http://github.com/matthuhiggins/foreigner/tree/master"
  s.rdoc_options = ["--line-numbers", "--main", "README"]
  s.require_paths = %w(lib)
  s.rubygems_version = "1.3.4"
  s.summary = "Foreign keys for Rails migrations"
  s.description = "Foreign keys for Rails migrations"
 
  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 1
  end
end
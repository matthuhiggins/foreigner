# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'foreigner'
  s.version = '0.9.2'
  s.summary = 'Foreign keys for Rails'
  s.description = 'Adds helpers to migrations and correctly dumps foreign keys to schema.rb'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Matthew Higgins'
  s.email             = 'developer@matthewhiggins.com'
  s.homepage          = 'http://github.com/matthuhiggins/foreigner'
  s.rubyforge_project = 'foreigner'

  s.extra_rdoc_files = ['README.rdoc']
  s.files = %w(MIT-LICENSE Rakefile README.rdoc) + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_paths = %w(lib)
  s.add_dependency('activerecord', '>= 3.0.0')
end

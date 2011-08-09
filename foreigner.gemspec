# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'foreigner'
  s.version = '1.1.0'
  s.summary = 'Foreign Keys for Rails'
  s.description = 'Adds helpers to migrations and dumps foreign keys to schema.rb'

  s.required_ruby_version     = '>= 1.8.7'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Matthew Higgins'
  s.email             = 'developer@matthewhiggins.com'
  s.homepage          = 'http://github.com/matthuhiggins/foreigner'
  s.rubyforge_project = 'foreigner'

  s.extra_rdoc_files = %w(README.rdoc)
  s.files = %w(MIT-LICENSE Rakefile README.rdoc) + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.add_dependency('activerecord', '>= 3.0.0')
  s.add_development_dependency('activerecord', '>= 3.1.0.rc5')
end

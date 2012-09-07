require 'rake'
# begin
#   require 'bundler/setup'
# rescue LoadError
#   puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
# end

require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = 'foreigner'
  gem.version = '1.2.1'
  gem.summary = 'Foreign Keys for Rails'
  gem.description = 'Adds helpers to migrations and dumps foreign keys to schema.rb'

  gem.required_ruby_version     = '>= 1.8.7'
  gem.required_rubygems_version = '>= 1.3.5'

  gem.author            = 'Matthew Higgins'
  gem.email             = 'developer@matthewhiggins.com'
  gem.homepage          = 'http://github.com/matthuhiggins/foreigner'
  gem.rubyforge_project = 'foreigner'

  gem.extra_rdoc_files = %w(README.rdoc)
  gem.files = %w(MIT-LICENSE Rakefile README.rdoc) + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  gem.add_dependency('activerecord', '>= 3.0.0')
  gem.add_development_dependency('activerecord', '>= 3.1.0')
end
Jeweler::RubygemsDotOrgTasks.new

desc 'Default: run unit tests.'
task :default => :test

require 'rake/testtask'
desc 'Test the foreigner plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

require 'rake'
# begin
#   require 'bundler/setup'
# rescue LoadError
#   puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
# end

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

require 'rake/testtask'

desc "Default task: Run tests"
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = false
  test.ruby_opts += ['-rubygems'] if defined? Gem
end

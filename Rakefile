require 'rake/testtask'

desc "Default task: Run tests"
task :default => :test

Rake::TestTask.new(:test) do |test|
  test.libs << "test"
  test.pattern = "test/**/*_test.rb"
  test.verbose = false
  test.ruby_opts += ['-rubygems'] if defined? Gem
end

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gemspec|
    gemspec.add_development_dependency "riot", "0.10.13"
    gemspec.add_development_dependency "rr", "0.10.9"
    gemspec.authors = ["Vladimir Andrijevik"]
    gemspec.description = <<-END_OF_DESCRIPTION.gsub(/^ */, "")
      Simpleton is a deployment micro-framework which aims to simplify and improve
      the deployment of web applications. In this regard, it is in the same space
      as Capistrano, Vlad the Deployer, and other similar tools.

      Simpleton is written in Ruby, and relies on existing UNIX command-line tools
      (`ssh`, `git`, etc.) to bring out the best of both worlds: a powerful DSL with
      testable deployment scripts, and of proven tools that are available
      (almost) everywhere.
    END_OF_DESCRIPTION
    gemspec.email = "vladimir+simpleton@andrijevik.net"
    gemspec.homepage = "http://github.com/vandrijevik/simpleton"
    gemspec.name = "simpleton"
    gemspec.summary = "Simpleton makes deploying server apps simple."
    gemspec.version = "0.3.0"
  end
rescue LoadError
  warn "Jeweler not available."
  warn "Install it with: gem i jeweler"
end

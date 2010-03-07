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
    gemspec.name = "simpleton"
    gemspec.summary = "Simpleton makes deploying server apps simple."
    gemspec.version = "0.1.0"
    gemspec.homepage = "http://github.com/vandrijevik/simpleton"
    gemspec.authors = ["Vladimir Andrijevik"]
    gemspec.email = "vladimir+simpleton@andrijevik.net"
    gemspec.description = <<-END_OF_DESCRIPTION.gsub(/^ */, "")
      Simpleton takes a simple, object-oriented approach to the way
      you deploy your server applications.
      
      With Simpleton, you express (and test) the things that need to
      happen during a deployment as Middleware objects. A Command Runner
      runs the command from a Middleware on a remote host, and
      Simpleton orchestrates the operation of Command Runners on the
      hosts you've configured.
      
      Simpleton ships with a few common Middleware, a couple of Command
      Runners, and makes it very easy to roll your own. Enjoy!
    END_OF_DESCRIPTION
  end
rescue LoadError
  warn "Jeweler not available."
  warn "Install it with: gem i jeweler"
end

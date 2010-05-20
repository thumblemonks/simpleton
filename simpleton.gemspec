Gem::Specification.new do |s|
  s.name    = "simpleton"
  s.version = "0.3.0"
  s.date    = Time.now.strftime('%Y-%m-%d')

  s.authors     = ["Vladimir Andrijevik"]
  s.email       = "vladimir+simpleton@andrijevik.net"
  s.homepage    = "http://github.com/vandrijevik/simpleton"
  s.summary     = "Simpleton makes deploying web applications simple."
  s.description = <<-END_OF_DESCRIPTION.gsub(/^ */, "")
    Simpleton is a deployment micro-framework which aims to simplify and improve
    the deployment of web applications. In this regard, it is in the same space
    as Capistrano, Vlad the Deployer, and other similar tools.

    Simpleton is written in Ruby, and relies on existing UNIX command-line tools
    (`ssh`, `git`, etc.) to bring out the best of both worlds: a powerful DSL with
    testable deployment scripts, and of proven tools that are available
    (almost) everywhere.
  END_OF_DESCRIPTION

  s.has_rdoc   = false
  s.files      = %w( README.md Rakefile LICENSE )
  s.files     += Dir.glob("lib/**/*")
  s.test_files = Dir.glob("test/**/*")

  s.add_dependency "session", "2.4.0"

  s.add_development_dependency "riot"
  s.add_development_dependency "rr"
end

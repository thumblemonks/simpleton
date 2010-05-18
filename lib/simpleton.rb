module Simpleton
  class Error < ::RuntimeError; end

  autoload :CommandRunner, "simpleton/command_runner"
  autoload :Middleware, "simpleton/middleware"
  autoload :Worker, "simpleton/worker"

  Configuration = {}
  MiddlewareChains = {}

  def self.configure
    yield Configuration
  end

  def self.use(middleware, opts={})
    applicable_locations = opts[:only] || Array(Configuration[:hosts])
    unless (user = Configuration[:user]).nil?
      applicable_locations = applicable_locations.map { |location| "#{user}@#{location}" }
    end

    applicable_locations.each do |location|
      MiddlewareChains[location] ||= []
      MiddlewareChains[location] << middleware
    end
  end

  def self.run(command_runner = Simpleton::CommandRunner)
    MiddlewareChains.each do |host, chain|
      fork { Worker.new(host, chain, command_runner).run }
    end

    Process.waitall.all? { |pid, status| status.success? } ? true : Process.exit(1)
  end
end

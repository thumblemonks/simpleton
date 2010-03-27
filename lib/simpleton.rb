module Simpleton
  class Error < ::RuntimeError; end

  autoload :CommandRunners, "simpleton/command_runners"
  autoload :Middleware, "simpleton/middleware"
  autoload :Worker, "simpleton/worker"

  Configuration = {}
  MiddlewareChains = {}

  def self.configure
    yield Configuration
  end

  def self.use(middleware, opts={})
    applicable_hosts = opts[:only] || Array(Configuration[:hosts])

    applicable_hosts.each do |host|
      MiddlewareChains[host] ||= []
      MiddlewareChains[host] << middleware
    end
  end

  def self.run(command_runner = Simpleton::CommandRunners::Open3)
    MiddlewareChains.each do |host, chain|
      fork { Worker.new(host, chain, command_runner).run }
    end

    Process.waitall.all? { |pid, status| status.success? } ? true : Process.exit(1)
  ensure
    MiddlewareChains.clear
  end
end

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
    specified_hosts = opts[:only]
    unless specified_hosts.nil? || (specified_hosts - configured_hosts).empty?
      raise Error, "Some of the specified hosts are not configured"
    end

    applicable_hosts = specified_hosts || configured_hosts
    raise Error, "This middleware would not apply to any configured hosts" if applicable_hosts.empty?

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

private
  def self.configured_hosts
    Array(Configuration[:hosts])
  end
end

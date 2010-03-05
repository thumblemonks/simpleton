module Simpleton
  autoload :CommandRunners, "simpleton/command_runners"
  autoload :Worker, "simpleton/worker"

  Configuration = {}
  MiddlewareChains = {}

  def self.configure
    yield Configuration
  end

  def self.use(middleware, opts={})
    specified_hosts = opts[:only]
    unless specified_hosts.nil? || (specified_hosts - configured_hosts).empty?
      raise ArgumentError, "Some of the specified hosts are not configured"
    end

    applicable_hosts = specified_hosts || configured_hosts
    raise ArgumentError, "This middleware would not apply to any configured hosts" if applicable_hosts.empty?

    applicable_hosts.each do |host|
      MiddlewareChains[host] ||= []
      MiddlewareChains[host] << middleware
    end
  end

  def self.run
    MiddlewareChains.each do |host, chain|
      fork { Worker.new(host, chain).run }
    end

    Process.waitall
  end

private
  def self.configured_hosts
    Array(Configuration[:hosts])
  end
end

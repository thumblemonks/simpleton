module Simpleton
  Configuration = {}
  MiddlewareChains = Hash.new { |hash, key| hash[key] = []; hash[key] }

  def self.configure
    yield Configuration
  end

  def self.use(middleware_class, opts={})
    specified_hosts = opts[:only]
    unless specified_hosts.nil? || (specified_hosts - configured_hosts).empty?
      raise ArgumentError, "Some of the specified hosts are not configured"
    end

    applicable_hosts = specified_hosts || configured_hosts
    raise ArgumentError, "This middleware would not apply to any configured hosts" if applicable_hosts.empty?

    applicable_hosts.each { |host| MiddlewareChains[host] << middleware_class.new }
  end

private
  def self.configured_hosts
    Array(Configuration[:hosts])
  end
end

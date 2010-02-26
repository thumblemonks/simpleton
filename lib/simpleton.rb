class Simpleton
  Configuration = {}
  MiddlewareChains = Hash.new { |hash, key| hash[key] = []; hash[key] }

  def self.configure
    yield Configuration
  end

  def self.use(middleware_class, opts={})
    configured_hosts = Array(Configuration[:hosts])

    specified_hosts = opts[:only]
    raise ArgumentError, "Some of the specified hosts are not configured" unless specified_hosts.nil? || (specified_hosts - configured_hosts).empty?

    applicable_hosts = specified_hosts || configured_hosts
    raise ArgumentError, "This middleware would not apply to any configured hosts" if applicable_hosts.empty?

    applicable_hosts.each { |host| MiddlewareChains[host] << middleware_class.new }
  end
end

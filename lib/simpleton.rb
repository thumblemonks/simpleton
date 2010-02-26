class Simpleton
  Configuration = {}
  MiddlewareChains = Hash.new { |hash, key| hash[key] = []; hash[key] }

  def self.configure
    yield Configuration
  end

  def self.use(middleware_class, opts={})
    applicable_hosts = opts[:only] || Array(Configuration[:hosts])
    raise ArgumentError, "This middleware would not apply to any configured hosts." if applicable_hosts.empty?

    applicable_hosts.each { |host| MiddlewareChains[host] << middleware_class.new }
  end
end

module Simpleton
  class Master
    attr_accessor :configuration, :middleware_chains

    def initialize
      @configuration = {}
      @middleware_chains = {}
    end

    def configure
      yield @configuration
    end

    def use(middleware, opts={})
      applicable_locations = opts[:only] || Array(configuration[:hosts])
      unless (user = configuration[:user]).nil?
        applicable_locations = applicable_locations.map { |location| "#{user}@#{location}" }
      end

      applicable_locations.each do |location|
        middleware_chains[location] ||= []
        middleware_chains[location] << middleware
      end
    end

    def run(command_runner = Simpleton::CommandRunner)
      middleware_chains.each do |location, chain|
        fork { Worker.new(location, chain, command_runner, configuration).run }
      end

      Process.waitall.all? { |pid, status| status.success? } ? true : Process.exit(1)
    end
  end
end

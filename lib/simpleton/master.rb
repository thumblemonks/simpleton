module Simpleton
  class Master
    attr_accessor :configuration, :middleware_queues

    def initialize
      @configuration = {}
      @middleware_queues = {}
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
        middleware_queues[location] ||= []
        middleware_queues[location] << middleware
      end
    end

    def run(worker_class = Simpleton::Worker)
      middleware_queues.each do |location, chain|
        fork { worker_class.new(location, chain, configuration).run }
      end

      Process.waitall.all? { |pid, status| status.success? } ? true : Process.exit(1)
    end
  end
end

module Simpleton
  class Worker
    attr_reader :host, :middleware_chain, :command_runner

    def initialize(host, middleware_chain, command_runner)
      @host = host
      @middleware_chain = middleware_chain
      @command_runner = command_runner
    end

    def run
      middleware_chain.all? do |middleware|
        command_runner.run(host, middleware.call(Configuration))
      end
    end
  end
end

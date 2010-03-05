module Simpleton
  class Worker
    attr_reader :host, :middleware_chain, :command_runner

    def initialize(host, middleware_chain, command_runner = Simpleton::CommandRunners::System)
      @host = host
      @middleware_chain = middleware_chain
      @command_runner = command_runner
    end

    def run
      middleware_chain.all? { |middleware| command_runner.run(host, middleware.call) }
    end
  end
end

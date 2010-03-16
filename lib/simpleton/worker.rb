module Simpleton
  class Worker
    attr_reader :host, :middleware_chain, :command_runner

    def initialize(host, middleware_chain, command_runner)
      @host = host
      @middleware_chain = middleware_chain
      @command_runner = command_runner
    end

    def run
      commands = middleware_chain.map { |middleware| middleware.call(Configuration)}

      if commands.all? { |command| command_runner.run(host, command) }
        Process.exit(0)
      else
        Process.exit(1)
      end
    end
  end
end

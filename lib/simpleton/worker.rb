module Simpleton
  class Worker
    attr_reader :location, :middleware_chain, :command_runner

    def initialize(location, middleware_chain, command_runner)
      @location = location
      @middleware_chain = middleware_chain
      @command_runner = command_runner
    end

    def run
      commands = middleware_chain.map { |middleware| middleware.call(Configuration)}

      if commands.all? { |command| command_runner.run(location, command) }
        Process.exit(0)
      else
        Process.exit(1)
      end
    end
  end
end

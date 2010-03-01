module Simpleton
  class Worker
    attr_reader :host, :middleware_chain, :command_runner

    def initialize(host, middleware_chain, command_runner = CommandRunners::System.new)
      @host = host
      @middleware_chain = middleware_chain
      @command_runner = command_runner
    end
  end
end

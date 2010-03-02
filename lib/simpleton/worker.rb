module Simpleton
  class Worker
    attr_reader :host, :middleware_chain

    def initialize(host, middleware_chain)
      @host = host
      @middleware_chain = middleware_chain
    end
  end
end

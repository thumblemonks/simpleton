require "session"

module Simpleton
  class Worker
    attr_reader :location, :middleware_chain, :configuration

    def initialize(location, middleware_chain, configuration)
      @location = location
      @middleware_chain = middleware_chain
      @configuration = configuration
    end

    def run
      commands = middleware_chain.map { |middleware| middleware.call(configuration) }
      shell = Session.new

      commands.each do |command|
        stdout, stderr = log_and_execute(shell, location, command)
        process_output(stdout, stderr)

        Process.exit(sh.exit_status) unless sh.exit_status.zero?
      end
    end

  private
    def log_and_execute(session, location, command)
      puts formatted_line(location, "<", command)
      session.execute("ssh #{location} '#{command}'", :stdin => StringIO.new)
    end

    def process_output(stdout, stderr)
      puts formatted_line(location, ">", stdout) unless stdout.empty?
      puts formatted_line(location, "E", stderr) unless stderr.empty?
    end

    def formatted_line(prefix, indicator, message)
      "[#{prefix}]#{indicator} #{message}"
    end
  end
end

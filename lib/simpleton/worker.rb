require "session"

module Simpleton
  class Worker
    attr_reader :location, :middleware_queue, :configuration

    def initialize(location, middleware_queue, configuration)
      @location = location
      @middleware_queue = middleware_queue
      @configuration = configuration
    end

    def run
      commands = middleware_queue.map { |middleware| middleware.call(configuration) }
      shell = Session.new

      commands.each do |command|
        log_command(command)
        stdout, stderr = execute(shell, location, command)
        log_output(stdout, stderr)

        Process.exit(shell.exit_status) unless shell.exit_status.zero?
      end
    end

  private
    def execute(session, location, command)
      session.execute("ssh #{location} '#{command}'", :stdin => StringIO.new)
    end

    def log_command(command)
      puts formatted_line(location, "<", command)
    end

    def log_output(stdout, stderr)
      puts formatted_line(location, ">", stdout) unless stdout.empty?
      puts formatted_line(location, "E", stderr) unless stderr.empty?
    end

    def formatted_line(prefix, indicator, message)
      "[#{prefix}]#{indicator} #{message}"
    end
  end
end

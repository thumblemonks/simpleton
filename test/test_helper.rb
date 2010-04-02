$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'riot'
require 'riot/rr'
require 'simpleton'

module Process
  # Ensure that Workers don't exit for real in tests
  def self.exit(*args); true; end
end

unless ENV["VERBOSE"]
  Riot.reporter = Riot::DotMatrixReporter
end
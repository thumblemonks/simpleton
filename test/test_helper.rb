$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'riot'
require 'riot/rr'
require 'simpleton'

module Kernel
  # Ensure that we don't call system commands for real in tests
  def system(*args); true; end

  # Ensure that we don't print messages to stdout for real in tests
  def puts(*args); end
end

module Process
  # Ensure that Workers don't exit for real in tests
  def self.exit(*args); true; end
end

unless ENV["VERBOSE"]
  Riot.reporter = Riot::DotMatrixReporter
end
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'riot'
require 'riot/rr'
require 'simpleton'

module Kernel
  # Ensure that we don't call system commands for reals in tests
  def system(*args); true; end

  # Ensure that we don't print messages to stdout for reals in tests
  def puts(*args); true; end
end

unless ENV["VERBOSE"]
  Riot.reporter = Riot::DotMatrixReporter
end
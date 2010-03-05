$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'riot'
require 'riot/rr'
require 'simpleton'

# Ensure that we don't call system commands for reals during the tests
class Simpleton::CommandRunners::System
  def self.system(*args); true; end
end

unless ENV["VERBOSE"]
  Riot.reporter = Riot::DotMatrixReporter
end
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'riot'
require 'riot/rr'
require 'simpleton'

unless ENV["VERBOSE"]
  Riot.reporter = Riot::DotMatrixReporter
end
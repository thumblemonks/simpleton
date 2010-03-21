module Simpleton
  module Middleware
    autoload :GitBootstrapper, "simpleton/middleware/git_bootstrapper"
    autoload :GitUpdater, "simpleton/middleware/git_updater"
    autoload :PassengerRestarter, "simpleton/middleware/passenger_restarter"
  end
end
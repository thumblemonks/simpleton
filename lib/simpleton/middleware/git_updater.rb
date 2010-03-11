module Simpleton
  module Middleware
    class GitUpdater
      def self.call(opts = {})
        commit, directory = opts.values_at(:commit, :directory)

        unless commit && directory
          raise Simpleton::Error, "GitUpdater requires the configuration parameters :commit and :directory"
        end

        "cd #{directory} && git fetch && git reset --hard #{commit}"
      end
    end
  end
end

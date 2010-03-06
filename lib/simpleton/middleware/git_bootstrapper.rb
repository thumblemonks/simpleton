module Simpleton
  module Middleware
    class GitBootstrapper
      def self.call(opts = {})
        directory, repository = opts.values_at(:directory, :repository)

        unless directory && repository
          raise Simpleton::Error, "GitBootstrapper requires the configuration parameters :directory and :repository"
        end

        "git clone #{repository} #{directory}"
      end
    end
  end
end

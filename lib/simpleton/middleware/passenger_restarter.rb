module Simpleton
  module Middleware
    class PassengerRestarter
      def self.call(opts = {})
        directory = opts[:directory]

        unless directory
          raise Simpleton::Error, "PassengerRestarter requires the configuration parameter :directory"
        end

        %Q[touch #{File.join(directory, "tmp", "restart.txt")}]
      end
    end
  end
end

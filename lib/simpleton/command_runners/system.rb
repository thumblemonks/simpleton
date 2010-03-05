module Simpleton
  module CommandRunners
    class System
      def self.run(host, command)
        system("ssh", host, command)
      end
    end
  end
end

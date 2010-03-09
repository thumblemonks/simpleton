module Simpleton
  module CommandRunners
    class SystemWithLogging < System
      def self.run(host, command)
        puts "[#{host}]: #{command}"
        super
      end
    end
  end
end

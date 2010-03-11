module Simpleton
  module CommandRunners
    class PercentXWithLogging < PercentX
      def self.run(host, command)
        puts "[#{host}]< #{command}"
        super
      end
    end
  end
end

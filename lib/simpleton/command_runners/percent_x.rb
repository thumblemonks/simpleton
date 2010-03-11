module Simpleton
  module CommandRunners
    class PercentX
      def self.run(host, command)
        output = execute("ssh #{host} #{command}")
        puts "[#{host}]> #{output}"
        $?.success?
      end

    private
      def self.execute(cmd)
        %x[cmd]
      end
    end
  end
end

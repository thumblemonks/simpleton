require 'open3'

module Simpleton
  module CommandRunners
    class Open3
      def self.run(host, command)
        puts "[#{host}]< #{command}"
        i,o,e = ::Open3.popen3 "ssh #{host} #{command}"

        unless (std_output = o.read).empty?
          puts "[#{host}]> #{std_output}"
        end

        unless (err_output = e.read).empty?
          puts "[#{host}]E #{err_output}"
        end

        err_output.empty? ? true : false
      end
    end
  end
end

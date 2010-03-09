require 'test_helper'

context "Simpleton::CommandRunners::SystemWithLogging" do
  setup { Simpleton::CommandRunners::SystemWithLogging }

  should "inherit from Simpleton::CommandRunners::System" do
    topic.ancestors.include?(Simpleton::CommandRunners::System)
  end
end

context "Simpleton::CommandRunners::SystemWithLogging.run" do
  setup { Simpleton::CommandRunners::SystemWithLogging }

  host = "host#{Time.now.to_i}"
  command = "echo 'Hello World'"
  context "with arguments (#{host}, #{command})" do
    should "output the host and command" do
      mock(topic).puts("[#{host}]: #{command}")
      topic.run(host, command)
      true
    end

    should %Q[call super] do
      mock(Simpleton::CommandRunners::System).system("ssh", "#{host}", "#{command}") {true}
      topic.run(host, command)
    end
  end
end

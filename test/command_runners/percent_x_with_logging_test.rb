require 'test_helper'

context "Simpleton::CommandRunners::PercentXWithLogging" do
  setup { Simpleton::CommandRunners::PercentXWithLogging }

  should "inherit from Simpleton::CommandRunners::PercentX" do
    topic.ancestors.include?(Simpleton::CommandRunners::PercentX)
  end
end

context "Simpleton::CommandRunners::PercentXWithLogging.run" do
  setup { Simpleton::CommandRunners::PercentXWithLogging }

  host = "host#{Time.now.to_i}"
  command = "echo 'Hello World'"
  should "display the host and command being run" do
    stub(Simpleton::CommandRunners::PercentX).run {true}
    mock(topic).puts("[#{host}]< #{command}")
    topic.run(host, command)
  end

  should %Q[call super] do
    mock(Simpleton::CommandRunners::PercentX).run(host, command) {true}
    topic.run(host, command)
  end
end

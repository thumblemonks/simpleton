require 'test_helper'

context "Simpleton::CommandRunners::PercentX.run" do
  setup { Simpleton::CommandRunners::PercentX }

  host = "host#{Time.now.to_i}"
  command = "echo 'Hello World'"
  mock_output = "Output #{Time.now.to_i}"

  should "display the command being run and its output" do
    mock(topic).puts("[#{host}]< #{command}")
    mock(topic).puts("[#{host}]> #{mock_output}")

    stub(topic).execute("ssh #{host} #{command}") {mock_output}
    stub($?).success? {true}

    topic.run(host, command)
  end

  asserts "that when the command fails, its return value" do
    stub(topic).execute("ssh #{host} #{command}") {mock_output}
    stub($?).success? {false}

    topic.run(host, command)
  end.equals(false)

  asserts "that when the command succeeds, its return value" do
    stub(topic).execute("ssh #{host} #{command}") {mock_output}
    stub($?).success? {true}

    topic.run(host, command)
  end.equals(true)
end

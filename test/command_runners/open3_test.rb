require 'test_helper'

context "Simpleton::CommandRunners::Open3.run" do
  setup { Simpleton::CommandRunners::Open3 }

  host = "host#{Time.now.to_i}"
  command = "echo 'Hello World'"

  context "with arguments (#{host}, #{command})" do
    should %Q[call Open3.popen("ssh #{host} #{command}")] do
      mock(::Open3).popen3("ssh #{host} #{command}") do
        [ StringIO.new, StringIO.new, StringIO.new ]
      end
      topic.run(host, command)
    end
  end

  should "display the command being run" do
    stub(topic).puts
    mock(topic).puts("[#{host}]< #{command}")

    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new, StringIO.new ]
    end

    topic.run(host, command)
  end

  should "display the standard output of the command when present" do
    std_output = "Output #{Time.now.to_i}"
    stub(topic).puts

    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new(std_output), StringIO.new ]
    end
    mock(topic).puts("[#{host}]> #{std_output}")

    topic.run(host, command)
  end

  should "not display the standard output of the command when there isn't any" do
    stub(topic).puts

    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new, StringIO.new ]
    end
    mock(topic).puts("[#{host}]> ").never

    topic.run(host, command)
  end

  should "display the error output of the command when present" do
    err_output = "Output #{Time.now.to_i}"
    stub(topic).puts

    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new, StringIO.new(err_output) ]
    end
    mock(topic).puts("[#{host}]E #{err_output}")

    topic.run(host, command)
    true
  end

  should "not display the error output of the command when there isn't any" do
    stub(topic).puts

    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new, StringIO.new ]
    end
    mock(topic).puts("[#{host}]E ").never

    topic.run(host, command)
  end

  asserts "that when there was error output, its return value" do
    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new, StringIO.new("error") ]
    end

    topic.run(host, command)
  end.equals(false)

  asserts "that when there was no error output, its return value" do
    stub(::Open3).popen3("ssh #{host} #{command}") do
      [ StringIO.new, StringIO.new, StringIO.new ]
    end

    topic.run(host, command)
  end.equals(true)
end

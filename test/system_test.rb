require 'test_helper'
require 'simpleton/command_runners/system'

host = "host#{Time.now.to_i}"
command = "echo 'Hello World'"
context "Simpleton::CommandRunners::System.run(#{host}, #{command})" do
  setup { Simpleton::CommandRunners::System }
  should %Q[call system("ssh", "#{host}", "#{command}")] do
    mock(topic).system("ssh", "#{host}", "#{command}") {true}
    topic.run(host, command)
  end
end

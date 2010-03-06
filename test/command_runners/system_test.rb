require 'test_helper'

context "Simpleton::CommandRunners::System.run" do
  setup { Simpleton::CommandRunners::System }

  host = "host#{Time.now.to_i}"
  command = "echo 'Hello World'"
  context "with arguments (#{host}, #{command})" do
    should %Q[call system("ssh", "#{host}", "#{command}")] do
      mock(topic).system("ssh", "#{host}", "#{command}") {true}
      topic.run(host, command)
    end
  end
end

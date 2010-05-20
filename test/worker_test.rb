require 'test_helper'

context "Simpleton::Worker.new" do
  location = "user@host"
  middleware_queue = [ Proc.new {"echo 123"} ]
  configuration = { :a => :b}

  context "with arguments (#{location}, #{middleware_queue.inspect}, #{configuration})" do
    setup { Simpleton::Worker.new(location, middleware_queue, configuration) }

    asserts(:location).equals(location)
    asserts(:middleware_queue).equals(middleware_queue)
    asserts(:configuration).equals(configuration)
  end
end

context "Simpleton::Worker#run" do
end

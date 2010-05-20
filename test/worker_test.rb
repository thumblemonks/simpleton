require 'test_helper'

context "Simpleton::Worker.new" do
  location = "user@host"
  middleware_chain = [ Proc.new {"echo 123"} ]
  configuration = { :a => :b}

  context "with arguments (#{location}, #{middleware_chain.inspect}, #{configuration})" do
    setup { Simpleton::Worker.new(location, middleware_chain, configuration) }

    asserts(:location).equals(location)
    asserts(:middleware_chain).equals(middleware_chain)
    asserts(:configuration).equals(configuration)
  end
end

context "Simpleton::Worker#run" do
end

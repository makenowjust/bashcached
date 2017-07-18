require_relative "test_helper"

describe "quit" do
  it "terminate the client connection" do
    with_bashcached_and_client do |client|
      client << "quit\r\n"
      client.gets.must_be_nil
    end
  end
end

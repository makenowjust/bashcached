require_relative "../test_helper"

describe "command/preppend" do
  it "does not prepend a value if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_prepend client, value: "test", not_stored: true
    end
  end

  it "prepends a value if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_prepend client, value: "test2"
      expect_get client, value: "test2test1"
    end
  end

  it "does not overwrite flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1", flags: 42
      expect_prepend client, value: "test2", flags: 21
      expect_get client, value: "test2test1", flags: 42
    end
  end

  it "does not overwrite exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1", exptime: 2
      expect_prepend client, value: "test2"
      expect_get client, value: "test2test1"
      sleep 2.5
      expect_not_get client
    end
  end

  it "prepends values multiple times" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      value = "test"
      5.times do |i|
        expect_prepend client, value: "test#{i}"
        value = "test#{i}#{value}"
      end
      expect_get client, value: value
    end
  end

  it "can be sent with noreply" do
    with_bashcached_and_client do |client|
      expect_append client, value: "test", noreply: true
      expect_not_get client
      client << "quit\r\n"
      client.gets.must_be_nil
    end
  end
end

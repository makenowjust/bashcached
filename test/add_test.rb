require_relative "test_helper"

describe "add" do
  it "stores a value if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_add client, value: "test"
      expect_get client, value: "test"
    end
  end

  it "does not store a value if the key exists (set)" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_add client, value: "test2", not_stored: true
      expect_get client, value: "test1"
    end
  end

  it "does not store a value if the key exists (add)" do
    with_bashcached_and_client do |client|
      expect_add client, value: "test1"
      expect_add client, value: "test2", not_stored: true
      expect_get client, value: "test1"
    end
  end

  it "stores a value with flags" do
    with_bashcached_and_client do |client|
      expect_add client, value: "test", flags: 42
      expect_get client, value: "test", flags: 42
    end
  end

  it "stores a value with exptime" do
    with_bashcached_and_client do |client|
      expect_add client, value: "test", exptime: 1
      expect_get client, value: "test"
      sleep 1.5
      expect_not_get client
    end
  end

  it "can be sent with noreply" do
    with_bashcached_and_client do |client|
      expect_add client, value: "test", noreply: true
      expect_get client, value: "test"
      client << "quit\r\n"
      client.gets.must_be_nil
    end
  end
end

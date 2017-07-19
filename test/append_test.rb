require_relative "test_helper"

describe "append" do
  it "does not append a value if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_append client, value: "test", not_stored: true
    end
  end

  it "appends a value if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_append client, value: "test2"
      expect_get client, value: "test1test2"
    end
  end

  it "does not overwrite flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1", flags: 42
      expect_append client, value: "test2", flags: 21
      expect_get client, value: "test1test2", flags: 42
    end
  end

  it "does not overwrite exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1", exptime: 2
      expect_append client, value: "test2"
      expect_get client, value: "test1test2"
      sleep 2.5
      expect_not_get client
    end
  end

  it "appends values multiple times" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      value = "test"
      5.times do |i|
        expect_append client, value: "test#{i}"
        value = "#{value}test#{i}"
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

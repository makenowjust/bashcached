require_relative "test_helper"

describe "replace" do
  it "does not store a value if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_replace client, value: "test", not_stored: true
    end
  end

  it "stores a value if the key exists (set)" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_replace client, value: "test2"
      expect_get client, value: "test2"
    end
  end

  it "stores a value if the key exists (set -> replace)" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_replace client, value: "test2"
      expect_replace client, value: "test3"
      expect_get client, value: "test3"
    end
  end

  it "stores a value if the key exists (add)" do
    with_bashcached_and_client do |client|
      expect_add client, value: "test1"
      expect_replace client, value: "test2"
      expect_get client, value: "test2"
    end
  end

  it "stores a value with flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1", flags: 21
      expect_replace client, value: "test2", flags: 42
      expect_get client, value: "test2", flags: 42
    end
  end

  it "stores a value with exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_replace client, value: "test2", exptime: 1
      expect_get client, value: "test2"
      sleep 1.5
      expect_not_get client
    end
  end

  it "overwrites exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_replace client, value: "test2", exptime: 1
      expect_replace client, value: "test3", exptime: 0
      expect_get client, value: "test3"
      sleep 1.5
      expect_get client, value: "test3"
    end
  end

  it "can be sent with noreply" do
    with_bashcached_and_client do |client|
      expect_replace client, value: "test", noreply: true
      expect_not_get client
      client << "quit\r\n"
      client.gets.must_be_nil
    end
  end
end

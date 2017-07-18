require_relative "test_helper"

describe "set" do
  it "sets a value with key and responds with 'STORED'" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
    end
  end

  it "can set a value multiple times" do
    with_bashcached_and_client do |client|
      expect_set client, key: "test1", value: "test"
      expect_set client, key: "test2", value: "test"
    end
  end

  it "can set a value with flags and exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", flags: 42
      expect_set client, value: "test", exptime: 42
      expect_set client, value: "test", flags: 42, exptime: 42
    end
  end

  it "can be sent with noreply" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", noreply: true
      expect_get client, value: "test"
      client << "quit\r\n"
      client.gets.must_be_nil
    end
  end

  it "can set an empty value" do
    with_bashcached_and_client do |client|
      expect_set client, value: ""
    end
  end

  it "can set a value including a white space" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test test"
    end
  end

  it "can set a value including a null character" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\0test"
    end
  end

  it "can set a value including new lines" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\ntest\rtest"
    end
  end

  it "can set a value including control characters" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\ttest\atest"
    end
  end

  it "can set a large value" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\r\n" * 1000
    end
  end

  it "can set a UTF-8 value" do
    with_bashcached_and_client do |client|
      expect_set client, value: "これはテストです。💯"
    end
  end
end

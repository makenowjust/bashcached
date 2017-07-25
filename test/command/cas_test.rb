require_relative "../test_helper"

describe "command/cas" do
  it "stores a value if cas_unique is correct" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_cas client, value: "test2", cas_unique: 1, result: "STORED"
      expect_gets client, value: "test2", cas_unique: 2
    end
  end

  it "does not store a value if cas_unique is wrong" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_set client, value: "test2"
      expect_cas client, value: "test3", cas_unique: 1, result: "EXISTS"
      expect_gets client, value: "test2", cas_unique: 2
    end
  end

  it "does not store a value if the key is not found" do
    with_bashcached_and_client do |client|
      expect_cas client, value: "test1", cas_unique: 1, result: "NOT_FOUND"
      expect_not_get client
    end
  end

  it "can set a flag" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_cas client, value: "test2", flags: 42, cas_unique: 1, result: "STORED"
      expect_gets client, value: "test2", flags: 42, cas_unique: 2
    end
  end

  it "can set an exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_cas client, value: "test2", exptime: 2, cas_unique: 1, result: "STORED"
      expect_gets client, value: "test2", cas_unique: 2
      sleep 2.5
      expect_not_get client
    end
  end
end

require_relative "test_helper"

describe "incr" do
  it "does not increment a value if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_incr client, expect: "NOT_FOUND"
    end
  end

  it "increments a value if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "0"
      expect_incr client, expect: 1
    end
  end

  it "increments values if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "0"
      expect_incr client, value: 42, expect: 42
    end
  end

  it "increments a value multiple times" do
    with_bashcached_and_client do |client|
      expect_set client, value: "0"
      5.times do |i|
        expect_incr client, expect: 1 + i
      end
    end
  end

  it "does not overwrite flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "0", flags: 42
      expect_incr client, expect: 1
      expect_get client, value: "1", flags: 42
    end
  end

  it "does not overwrite flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "0", exptime: 1
      expect_incr client, expect: 1
      sleep 1.5
      expect_not_get client
    end
  end
end

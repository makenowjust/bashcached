require_relative "test_helper"

describe "decr" do
  it "does not decrement a value if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_decr client, expect: "NOT_FOUND"
    end
  end

  it "decrements a value if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "42"
      expect_decr client, expect: 41
    end
  end

  it "decrements values if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "42"
      expect_decr client, value: 42, expect: 0
    end
  end

  it "decrements a value multiple times" do
    with_bashcached_and_client do |client|
      expect_set client, value: "42"
      5.times do |i|
        expect_decr client, expect: 41 - i
      end
    end
  end

  it "does not overwrite flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "42", flags: 42
      expect_decr client, expect: 41
      expect_get client, value: "41", flags: 42
    end
  end

  it "does not overwrite flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "42", exptime: 1
      expect_decr client, expect: 41
      sleep 1.5
      expect_not_get client
    end
  end
end

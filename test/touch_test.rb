require_relative "test_helper"

describe "touch" do
  it "does not set exptime if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_touch client, exptime: 0, not_found: true
    end
  end

  it "sets exptime if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", exptime: 0
      expect_touch client, exptime: 1
      expect_get client, value: "test"
      sleep 1.5
      expect_not_get client
    end
  end

  it "can be sent with noreply" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", exptime: 0
      expect_touch client, exptime: 1, noreply: true
      expect_get client, value: "test"
      sleep 1.5
      expect_not_get client
    end
  end
end

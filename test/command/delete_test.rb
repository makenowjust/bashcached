require_relative "../test_helper"

describe "command/delete" do
  it "does not delete the key if the key does not exist" do
    with_bashcached_and_client do |client|
      expect_delete client, not_found: true
    end
  end

  it "deletes the key if the key exists" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      expect_get client, value: "test"
      expect_delete client
      expect_not_get client
    end
  end

  it "can be sent with noreply" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      expect_get client, value: "test"
      expect_delete client, noreply: true
      expect_not_get client
    end
  end
end

require_relative "../test_helper"

describe "command/gets" do
  it "can get cas unique" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      expect_gets client, value: "test", cas_unique: 1
    end
  end

  it "returns same cas unique when not changed" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      expect_gets client, value: "test", cas_unique: 1
      expect_gets client, value: "test", cas_unique: 1
    end
  end

  it "returns another cas unique when changed" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1"
      expect_gets client, value: "test1", cas_unique: 1
      expect_set client, value: "test2"
      expect_gets client, value: "test2", cas_unique: 2
    end
  end

  it "returns another cas unique by each keys" do
    with_bashcached_and_client do |client|
      expect_set client, key: "test1", value: "test1"
      expect_gets client, key: "test1", value: "test1", cas_unique: 1
      expect_set client, key: "test2", value: "test2"
      expect_gets client, key: "test2", value: "test2", cas_unique: 2
    end
  end

  it "can get many keys at once" do
    with_bashcached_and_client do |client|
      expect_set client, key: "test1", value: "test1"
      expect_set client, key: "test2", value: "test2"
      expect_get_many client, {
        "test1" => {value: "test1", cas_unique: 1},
        "test2" => {value: "test2", cas_unique: 2},
      }
    end
  end

  it "can get flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", flags: 42
      expect_gets client, value: "test", flags: 42, cas_unique: 1
    end
  end
end

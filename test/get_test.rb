require_relative "test_helper"

describe "get" do
  it "gets a stored value" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      expect_get client, value: "test"
    end
  end

  it "can get a stored value by another client" do
    with_bashcached do
      with_client do |client|
        expect_set client, value: "test"
      end
      with_client do |client|
        expect_get client, value: "test"
      end
    end
  end

  it "can get a value multiple times" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test"
      expect_get client, value: "test"
      expect_get client, value: "test"
    end
  end

  it "can get many values" do
    with_bashcached_and_client do |client|
      expect_set client, key: "test1", value: "test"
      expect_set client, key: "test2", value: "test"
      expect_get_many client, "test1" => "test", "test2" => "test"
    end
  end

  it "can get a value with flags" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", flags: 42
      expect_get client, value: "test", flags: 42
    end
  end

  it "cannot get a value after exptime (<= 2592000)" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", exptime: 1
      expect_get client, value: "test"
      sleep 1.5
      expect_not_get client
    end
  end

  it "cannot get a value after exptime (> 2592000)" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test", exptime: Time.now.to_i + 1
      expect_get client, value: "test"
      sleep 1.5
      expect_not_get client
    end
  end

  it "overwrites exptime" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test1", exptime: 1
      expect_set client, value: "test2", exptime: 0
      expect_get client, value: "test2"
      sleep 1.5
      expect_get client, value: "test2"
    end
  end


  it "can get an empty value" do
    with_bashcached_and_client do |client|
      expect_set client, value: ""
      expect_get client, value: ""
    end
  end

  it "can get a value including a white space" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test test"
      expect_get client, value: "test test"
    end
  end

  it "can get a value including a null character" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\0test"
      expect_get client, value: "test\0test"
    end
  end

  it "can get a value including new lines" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\ntest\rtest"
      expect_get client, value: "test\ntest\rtest"
    end
  end

  it "can get a value including control characters" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\ttest\atest"
      expect_get client, value: "test\ttest\atest"
    end
  end

  it "can get a large value" do
    with_bashcached_and_client do |client|
      expect_set client, value: "test\r\n" * 1000
      expect_get client, value: "test\r\n" * 1000
    end
  end

  it "can get a UTF-8 value" do
    with_bashcached_and_client do |client|
      expect_set client, value: "これはテストです。💯"
      expect_get client, value: "これはテストです。💯"
    end
  end
end
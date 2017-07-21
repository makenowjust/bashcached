require_relative "test_helper"

describe "version" do
  it "returns a version string" do
    skip "bashcached doesn't know memcached version" if TEST_MEMCACHED

    expect_version = `./bashcached --version`.chomp
    with_bashcached_and_client do |client|
      client << "version\r\n"
      version = client.gets
      version.must_equal "VERSION #{expect_version}\r\n"
    end
  end
end

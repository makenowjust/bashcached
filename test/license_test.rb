require_relative "test_helper"

describe "license" do
  it "'bashcached --license' output is same as LICENSE files" do
    skip "this spec is not related to memcached" if TEST_MEMCACHED

    license = "#{File.read("LICENSE.md")}\n#{File.read("LICENSE.🍣.md")}"
    output = `./bashcached --license`
    license.must_equal output
  end
end

require_relative "test_helper"

describe "readme" do
  it "'bashcached --help' output is same" do
    skip "this spec is not related to memcached" if TEST_MEMCACHED

    readme = File.read("README.md")
                 .match(%r{(?<=^\$ \.\/bashcached --help\n).*?(?=^\$ )}m)
                 .to_s
    help = `./bashcached --help`
    readme.must_equal help
  end

  it "example can run" do
    example = File.read("README.md")
                  .match(%r{(?<=^\$ telnet localhost 25252\n).*?(?=^```)}m)
                  .to_s
                  .lines
                  .map(&:chomp)
                  # TODO: .lines(chomp: true)
                  # ruby on ubuntu 17.10 is still 2.3.x...
    with_bashcached_and_client do |client|
      while example.empty?
        case line = example.shift
        when /\Aversion/
          client << "#{line}\r\n"
          client.gets.must_equal "#{example.shift}\r\n"
        when /\Aset/
          client << "#{line}\r\n"
          client << "#{example.shift}\r\n"
          client.gets.must_equal "#{example.shift}\r\n"
        when /\Aget/
          client << "#{line}\r\n"
          client.gets.must_equal "#{example.shift}\r\n"
          client.gets.must_equal "#{example.shift}\r\n"
        when /\Aquit/
          client << "#{line}\r\n"
          client.gets.must_be_nil
        end
      end
    end
  end
end

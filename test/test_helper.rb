require "minitest/autorun"
require "minitest/pride"

require "open3"
require "socket"
require "timeout"

def with_command(command, timeout:)
  Open3.popen3(*command, pgroup: true) do |*, thread|
    begin
      Timeout.timeout(timeout) { yield }
    ensure
      # Wait to prevent to send a signal to unstable process
      # TODO: not perfect, but it works
      sleep 0.1

      # Send SIGINT to the process group
      Process.kill "INT", -thread.pid
    end

    begin
      Timeout.timeout(0.1) { thread.value.success?.must_equal true }
    rescue Timeout::Error
      Process.kill "INT", -thread.pid
      # TODO: retry limit is needed?
      retry
    end
  end
end

TEST_MEMCACHED = ENV.has_key?("TEST_MEMCACHED")
SERVER_COMMAND = TEST_MEMCACHED ? "memcached -p 25252" : "./bashcached"

def with_bashcached(opts = "", timeout: 3)
  with_command("#{SERVER_COMMAND} #{opts}", timeout: timeout) do
    # Wait to start a bashcached server
    # TODO: find better way (e.g. using 'expect' library)
    sleep 0.1
    yield
  end
  nil
end

def with_client(port = 25252)
  TCPSocket.open("localhost", 25252) do |client|
    yield client
  end
  nil
end

def with_bashcached_and_client
  with_bashcached do
    with_client do |client|
      yield client
    end
  end
end

def write_store_command(client, command, key, flags, exptime, value, noreply)
  client << "#{command} #{key} #{flags} #{exptime} #{value.bytesize}#{noreply ? " noreply" : ""}\r\n"
  client << "#{value.b}\r\n"
end

def expect_set(client, key: "test", value:, flags: 0, exptime: 0, noreply: false)
  write_store_command client, "set", key, flags, exptime, value, noreply
  client.gets.must_equal "STORED\r\n" unless noreply
end

def expect_add(client, key: "test", value:, flags: 0, exptime: 0, noreply: false, not_stored: false)
  write_store_command client, "add", key, flags, exptime, value, noreply
  unless noreply
    client.gets.must_equal "#{not_stored ? "NOT_STORED" : "STORED"}\r\n"
  end
end

def expect_replace(client, key: "test", value:, flags: 0, exptime: 0, noreply: false, not_stored: false)
  write_store_command client, "replace", key, flags, exptime, value, noreply
  unless noreply
    client.gets.must_equal "#{not_stored ? "NOT_STORED" : "STORED"}\r\n"
  end
end

def expect_append(client, key: "test", value:, flags: 0, exptime: 0, noreply: false, not_stored: false)
  write_store_command client, "append", key, flags, exptime, value, noreply
  unless noreply
    client.gets.must_equal "#{not_stored ? "NOT_STORED" : "STORED"}\r\n"
  end
end

def expect_prepend(client, key: "test", value:, flags: 0, exptime: 0, noreply: false, not_stored: false)
  write_store_command client, "prepend", key, flags, exptime, value, noreply
  unless noreply
    client.gets.must_equal "#{not_stored ? "NOT_STORED" : "STORED"}\r\n"
  end
end

def expect_get(client, key: "test", value:, flags: 0)
  expect_get_many client, key => {value: value, flags: flags}
end

def expect_not_get(client, key: "test")
  client << "get #{key}\r\n"
  client.gets.must_equal "END\r\n"
end

def expect_get_many(client, expects)
  client << "get #{expects.keys.join " "}\r\n"
  until expects.empty?
    if client.gets =~ /VALUE (?<key>[^ ]+) (?<flags>[^ ]+) (?<bytes>[^ ]+)\r\n/
      expect = expects.delete $~[:key]
      if expect.is_a?(Hash)
        expect_value = expect[:value]
        expect_flags = expect[:flags]&.to_s || "0"
      else
        expect_value = expect
        expect_flags = "0"
      end

      $~[:flags].must_equal expect_flags
      client.read($~[:bytes].to_i).must_equal expect_value.b
      client.gets.must_equal "\r\n"
    end
  end
  client.gets.must_equal "END\r\n"
end

def expect_delete(client, key: "test", noreply: false, not_found: false)
  client << "delete #{key}#{noreply ? " noreply" : ""}\r\n"
  unless noreply
    client.gets.must_equal "#{not_found ? "NOT_FOUND" : "DELETED"}\r\n"
  end
end

def expect_touch(client, key: "test", exptime:, noreply: false, not_found: false)
  client << "touch #{key} #{exptime}#{noreply ? " noreply" : ""}\r\n"
  unless noreply
    client.gets.must_equal "#{not_found ? "NOT_FOUND" : "TOUCHED"}\r\n"
  end
end

def expect_incr(client, key: "test", value: 1, noreply: false, expect:)
  client << "incr #{key} #{value}#{noreply ? " noreply" : ""}\r\n"
  unless noreply
    client.gets.must_equal "#{expect}\r\n"
  end
end

def expect_decr(client, key: "test", value: 1, noreply: false, expect:)
  client << "decr #{key} #{value}#{noreply ? " noreply" : ""}\r\n"
  unless noreply
    client.gets.must_equal "#{expect}\r\n"
  end
end

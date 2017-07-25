require "minitest/autorun"
require "minitest/pride"

require "open3"
require "socket"
require "timeout"

TEST_MEMCACHED = ENV.has_key?("TEST_MEMCACHED")

class MiniTest::Test
  def retry_on_error(times: 10, delay: 0.1, error_class: StandardError)
    (1..times).each do |i|
      begin
        return yield
      rescue error_class
        sleep delay
        raise if i == times
        next
      end
    end
  end

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

      # Cool down...
      sleep 0.1
    end
  end

  def with_bashcached(opts = "", timeout: 5)
    command = TEST_MEMCACHED ? "memcached -p 25252" : "./bashcached"
    with_command("#{command} #{opts}", timeout: timeout) do
      # Wait to start a bashcached server
      # TODO: find better way (e.g. using 'expect' library)
      sleep 0.1
      yield
    end
    nil
  end

  def with_client(port = 25252)
    # Sometimes TCPSocket.new is failed, so retry_on_error is needed.
    client = retry_on_error { TCPSocket.new("localhost", port) }
    yield client
    nil
  ensure
    client&.close
  end

  def with_bashcached_and_client
    with_bashcached do
      with_client do |client|
        yield client
      end
    end
  end

  def write_store_command(client, command, key, flags, exptime, value, noreply, cas_unique = nil)
    client << "#{command} #{key} #{flags} #{exptime} #{value.bytesize}#{cas_unique && " #{cas_unique}"}#{noreply ? " noreply" : ""}\r\n"
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

  def expect_cas(client, key: "test", value:, flags: 0, exptime: 0, cas_unique:, noreply: false, result:)
    write_store_command client, "cas", key, flags, exptime, value, noreply, cas_unique
    unless noreply
      client.gets.must_equal "#{result}\r\n"
    end
  end

  def expect_get(client, key: "test", value:, flags: 0)
    expect_get_many client, key => {value: value, flags: flags}
  end

  def expect_not_get(client, key: "test")
    client << "get #{key}\r\n"
    client.gets.must_equal "END\r\n"
  end

  def expect_gets(client, key: "test", value:, cas_unique:, flags: 0)
    expect_get_many client, key => {value: value, cas_unique: cas_unique, flags: flags}
  end

  VALUE_LINE_RE = %r{
    \A
    VALUE
    \ (?<key>[^\ ]+)
    \ (?<flags>\d+)
    \ (?<bytes>\d+)
    (?:\ (?<cas_unique>\d+))?
    \r\n
    \z
  }x

  def expect_get_many(client, expects)
    command = expects.first.last.has_key?(:cas_unique) ? "gets" : "get"
    client << "#{command} #{expects.keys.join " "}\r\n"
    while !expects.empty? && (line = client.gets)
      if line =~ VALUE_LINE_RE
        expect = expects.delete $~[:key]
        expect_value = expect[:value]
        expect_flags = expect[:flags]&.to_s || "0"
        expect_cas_unique = expect[:cas_unique]&.to_s

        $~[:flags].must_equal expect_flags
        $~[:cas_unique].must_equal expect_cas_unique if expect_cas_unique
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
end

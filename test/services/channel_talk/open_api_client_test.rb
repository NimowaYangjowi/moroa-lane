require "test_helper"

module ChannelTalk
  class OpenApiClientTest < ActiveSupport::TestCase
    test "raises when credentials are missing" do
      with_env("CHANNELTALK_ACCESS_KEY" => nil, "CHANNELTALK_ACCESS_SECRET" => nil) do
        error = assert_raises(OpenApiClient::ConfigurationError) { OpenApiClient.from_env }

        assert_equal "CHANNELTALK_ACCESS_KEY is required", error.message
      end
    end

    test "creates an event with server credentials" do
      captured_requests = []
      client = OpenApiClient.new(
        access_key: "access-key",
        access_secret: "access-secret",
        base_url: "https://api.example.test"
      )

      with_net_http_response({ event: { id: "event-1" } }, captured_requests) do
        event = client.create_event(
          user_id: "channel-user-1",
          name: "Purchase",
          property: { orderId: "1" }
        )

        assert_equal "event-1", event.fetch("id")
      end

      captured_request = captured_requests.first
      assert_equal "/open/v5/users/channel-user-1/events", captured_request.uri.path
      assert_equal "access-key", captured_request["x-access-key"]
      assert_equal "access-secret", captured_request["x-access-secret"]
      assert_equal "application/json", captured_request["content-type"]
      assert_equal(
        { "name" => "Purchase", "property" => { "orderId" => "1" } },
        JSON.parse(captured_request.body)
      )
    end

    private

    def with_env(values)
      previous_values = values.transform_values { |_value| nil }
      values.each do |key, value|
        previous_values[key] = ENV[key]
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end

      yield
    ensure
      previous_values.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end

    def with_net_http_response(body, captured_requests)
      original_start = Net::HTTP.method(:start)
      response = Net::HTTPOK.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, JSON.generate(body))

      fake_http = Object.new
      fake_http.define_singleton_method(:request) do |request|
        captured_requests << request
        response
      end

      Net::HTTP.define_singleton_method(:start) do |_host, _port, use_ssl:, open_timeout:, read_timeout:, &http_block|
        raise "expected HTTPS" unless use_ssl
        raise "unexpected open timeout" unless open_timeout == 5
        raise "unexpected read timeout" unless read_timeout == 5

        http_block.call(fake_http)
      end

      yield
    ensure
      Net::HTTP.define_singleton_method(:start, original_start)
    end
  end
end

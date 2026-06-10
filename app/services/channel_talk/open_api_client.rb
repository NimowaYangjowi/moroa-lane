require "json"
require "net/http"
require "uri"

module ChannelTalk
  class OpenApiClient
    class ConfigurationError < StandardError; end

    class Error < StandardError
      attr_reader :status, :response_body

      def initialize(message, status: nil, response_body: nil)
        super(message)
        @status = status
        @response_body = response_body
      end
    end

    def self.from_env
      access_key = ENV["CHANNELTALK_ACCESS_KEY"].presence
      access_secret = ENV["CHANNELTALK_ACCESS_SECRET"].presence

      raise ConfigurationError, "CHANNELTALK_ACCESS_KEY is required" unless access_key
      raise ConfigurationError, "CHANNELTALK_ACCESS_SECRET is required" unless access_secret

      new(
        access_key:,
        access_secret:,
        base_url: ENV["CHANNELTALK_API_BASE_URL"].presence || "https://api.channel.io"
      )
    end

    def initialize(access_key:, access_secret:, base_url:)
      @access_key = access_key
      @access_secret = access_secret
      @base_url = base_url.delete_suffix("/")
    end

    def get_user_by_member_id(member_id)
      response = request(Net::HTTP::Get.new(uri_for("/open/v5/users/@#{escape_path(member_id)}")))
      response.fetch("user")
    end

    def create_event(user_id:, name:, property:)
      http_request = Net::HTTP::Post.new(uri_for("/open/v5/users/#{escape_path(user_id)}/events"))
      http_request.body = JSON.generate({ name:, property: })

      response = request(http_request)
      response.fetch("event")
    end

    private

    attr_reader :access_key, :access_secret, :base_url

    def request(request)
      request["accept"] = "application/json"
      request["content-type"] = "application/json"
      request["x-access-key"] = access_key
      request["x-access-secret"] = access_secret

      response = Net::HTTP.start(
        request.uri.hostname,
        request.uri.port,
        use_ssl: request.uri.scheme == "https",
        open_timeout: 5,
        read_timeout: 5
      ) { |http| http.request(request) }

      parsed_body = parse_body(response)
      return parsed_body if response.is_a?(Net::HTTPSuccess)

      raise Error.new(
        "ChannelTalk API request failed with HTTP #{response.code}",
        status: response.code.to_i,
        response_body: response.body
      )
    end

    def parse_body(response)
      JSON.parse(response.body.presence || "{}")
    rescue JSON::ParserError
      raise Error.new(
        "ChannelTalk API returned invalid JSON",
        status: response.code.to_i,
        response_body: response.body
      )
    end

    def uri_for(path)
      URI("#{base_url}#{path}")
    end

    def escape_path(value)
      URI.encode_www_form_component(value.to_s)
    end
  end
end

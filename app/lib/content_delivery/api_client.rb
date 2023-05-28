# frozen_string_literal: true

require 'digest'

module ContentDelivery
  class ApiClient
    URL = "https://cdn.contentful.com/spaces/#{ENV.fetch('SPACE_ID', nil)}".freeze

    def self.default
      @default ||= Client.new
    end

    def initialize
      @client = Faraday.new(*config) do |f|
        f.request :json
        f.response :json
        f.response :raise_error
        f.response :retry, retry_options
        f.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug do |formatter|
          formatter.filter(/^(Authorization:).+$/i, '\1[REDACTED]')
        end
        f.adapter :net_http
      end
    end

    def call(verb, api_path)
      cache = Digest::SHA256.hexdigest({ path: api_path }.inspect)
      circuit.try_run(cache:) do
        response = @client.public_send(verb, "#{URL}#{api_path}")
        response.body
      end
    end

    private

    def circuit
      @circuit ||= Faulty.circuit(
        :content_delivery,
        cache_expires_in: 1.day,
        cache_refresh: 1.hour,
        evaluation_window: 10.minutes
      )
    end

    def retry_options
      {
        max: 5,
        interval: 0.5,
        backoff_factor: 2,
        interval_randomness: 0.5,
        retry_status: [429],
        methods: [:get]
      }
    end

    def config
      [
        {
          headers: {
            authorization: "Bearer #{ENV.fetch('AUTH_TOKEN', nil)}"
          },
          request: {
            open_timeout: 1,
            read_timeout: 5,
            write_timeout: 5
          }
        }
      ]
    end
  end
end
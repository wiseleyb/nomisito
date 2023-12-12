# frozen_string_literal: true

module ApiRecipe
  class Utils
    class << self
      def http_get(uri, headers: nil, pause: nil)
        headers ||= { 'Accept' => 'application/json' }

        puts "HTTP GET: #{uri}"

        response = HTTParty.get(uri.to_s, headers:)
        sleep pause.to_i if pause
        response
      end

      def http_post(uri, headers: nil, body: {}, pause: nil)
        headers ||= {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }

        puts ''
        puts "Requesting: #{uri}"
        puts "Body: #{body}"

        response = HTTParty.post(uri.to_s, body:, headers:)
        sleep pause.to_i if pause
        response
      end
    end
  end
end

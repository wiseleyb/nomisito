# frozen_string_literal: true

module ApiRecipe
  class Utils
    class << self
      def http_get(uri, headers: nil, pause: nil)
        headers ||= { 'Accept' => 'application/json' }

        puts "HTTP GET: #{uri}"

        response = HTTParty.get(uri.to_s, headers:)
        delay(pause)
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
        delay(pause)
        response
      end

      # You can mock this out in specs to speed up initial run until
      # cached by VCR: allow(ApiRecipe::Utils).to receive(:delay)
      def delay(pause)
        sleep pause.to_i if pause
      end
    end
  end
end

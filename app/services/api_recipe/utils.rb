# frozen_string_literal: true

module ApiRecipe
  class Utils
    class << self
      # TODO: add standard time, retry logic
      def http_get(uri, headers: nil, pause: nil)
        headers ||= { 'Accept' => 'application/json' }

        log(name,
            'http_get',
            {
              uri: uri.to_s,
              headers:,
              pause:
            })

        response = HTTParty.get(uri.to_s, headers:)
        delay(pause)
        response
      end

      # TODO: add standard time, retry logic
      def http_post(uri, headers: nil, body: {}, pause: nil)
        headers ||= {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }

        log(name,
            'http_post',
            {
              uri: uri.to_s,
              headers:,
              body:,
              pause:
            })

        response = HTTParty.post(uri.to_s, body:, headers:)
        delay(pause)
        response
      end

      # You can mock this out in specs to speed up initial run until
      # cached by VCR: allow(ApiRecipe::Utils).to receive(:delay)
      # TODO: There are better ways to manage rate limiting... this is just a
      #       quick hack. Like you should do these as fast as possible until a
      #       pause is required. Easy problem to solve - over hte top for this.
      def delay(pause)
        sleep pause.to_i if pause
      end

      # Centralize logging
      # Format allows easy tailing/filter of logs
      # Example log: "source=recipe method=search title=chicken"
      def log(source, method, data = {})
        lstr = {
          source:,
          method:
        }.merge(data).map { |k, v| "#{k}=#{v}" }.join(' ')
        Rails.logger.info(lstr)
        return lstr unless Rails.env.development?

        puts ''
        puts "LOG: #{lstr}"
        puts ''
        lstr
      end

      def log_err(source, method, err, data = {})
        log(source, method, data.merge({ error: err.message }))
      end
    end
  end
end

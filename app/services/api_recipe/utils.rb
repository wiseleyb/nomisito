# frozen_string_literal: true

module ApiRecipe
  # Misc utils used in Api Recipe code
  class Utils
    class << self
      # Does a basic HTTP get
      # @param [String] uri (or URI object) to get
      # @param [Hash, nil] headers hash defaults to application/json
      # @param [Integer, nil] pause amount of time to sleep for
      # (this is for crude rate limiting)
      #
      # @return [Hash] standard return hash from HTTP
      def http_get(uri, headers: nil, pause: nil)
        # TODO: add standard time, retry logic
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

      # Does a basic HTTP post
      # @param [String] uri (or URI object) to get
      # @param [Hash, nil] headers hash - defaults to application/json
      # @param [Hash] body optional the body to post
      # @param [Integer, nil] pause amount of time to sleep for
      # (this is for crude rate limiting)
      #
      # @return [Hash] standard return hash from HTTP
      def http_post(uri, headers: nil, body: {}, pause: nil)
        # TODO: add standard time, retry logic
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

      # Adds a hacky rate-limiting option via sleep.
      #
      # You can mock this out in specs to speed up initial run until
      # cached by VCR: allow(ApiRecipe::Utils).to receive(:delay)
      #
      # @param [Integer] pause sleep for pause seconds
      def delay(pause)
        # TODO: There are better ways to manage rate limiting... this is just a
        #       quick hack. Like you should do these as fast as possible until a
        #       pause is required. Easy problem to solve - over hte top for this.
        sleep pause.to_i if pause
      end

      # Helper method for logging
      #
      # @param [String] source name of class/source/lib
      # @param [String] method name of what's being logged
      # @param [Hash, nil] data  hash of other params to log
      #
      # @example
      #   ApiRecipe::Utils.log('ApiRecipe::GuacIsExtra',
      #                        'search',
      #                        { query: 'chicken' })
      #   Would log something like
      #     source=ApiRecipe::GuacIsExtra method=search query=chicken
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

      # Helper method for logging
      #
      # @param [String] source name of class/source/lib
      # @param [String] method name of what's being logged
      # @param [RuntimeError] err err object to log. Just logs err.message
      # @param [Hash, nil] data hash of other params to log
      #
      # @example
      #   ApiRecipe::Utils.log('ApiRecipe::GuacIsExtra',
      #                        'search',
      #                        RuntimeError.new('oops'),
      #                        { query: 'bob' })
      #   Would log something like
      #     source=ApiRecipe::GuacIsExtra method=search query=bob error: oops
      def log_err(source, method, err, data = {})
        log(source, method, data.merge({ error: err.message }))
      end
    end
  end
end

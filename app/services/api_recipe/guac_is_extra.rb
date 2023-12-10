# frozen_string_literal: true

module ApiRecipe
  class GuacIsExtra
    class << self
      # Fetches ingredient list from all configured recipe urls
      def fetch_ingredients
        # TODO: This should accomodate bad data
        data = fetch_all
        data.map { |recipe| recipe['ingredients'] }
            .map { |rec| rec.map { |ing| ing['name'] } }
            .flatten.uniq.sort
      end

      def fetch_all
        # TODO: While mostly for setup - IRL you should add retry logic
        #       here for http errors
        url = 'https://guac-is-extra.herokuapp.com/'
        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body
        JSON.parse(data)
      end

      def cache_ingredients
        fetch_ingredients.each do |ing|
          next if ing.to_s.strip.blank?

          puts "Adding: #{ing.downcase}"
          Ingredient.where(name: ing.downcase,
                           site_klass: name).first_or_create
        end
      end

      def reset_cache!
        Ingredient.where(site_klass: name).destroy_all
      end
    end
  end
end

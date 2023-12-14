# frozen_string_literal: true

module ApiRecipe
  # Works with Edamam Food Database API
  #
  # Requires API keys EDAMAM_APP_ID and EDAMAM_APP_KEY. You can get this by
  # signing up or see a developer for values.
  #
  # Edamam API is rate limited to around 35/req/min. We handle this crudely
  # right now with sleep commands. You can mock out sleep in
  # ApiRecipe::Utils.pause to speed things up if needed (for tests, etc.)
  #
  # Api Docs URL: https://developer.edamam.com/food-database-api-docs
  class Edamam
    class << self
      # Fetches all dietary information for all ingredients in the DB. This
      # can be slow but should only need to be run once (or maybe updated
      # now and then) when you setup the site.
      #
      # @param [String, nil] site_klass to filter
      #
      # @example Load ingredients for GuacIsExtra API
      #   sk = 'ApiRecipe::GuacIsExtra'.constantize
      #   sk.reset_cache!
      #   sk.cache_ingredients
      #   ApiRecipe::Edamam.fetch_all_dietary(site_klass: sk.name)
      #   Dietary.reset!(site_klass: sk.name)
      def fetch_all_dietary(site_klass: nil)
        arel = Ingredient.where(edamam_results: {})
        arel = arel.where(site_klass:) if site_klass
        arel.find_each do |ing|
          fetch_data(ing.id)
        end
      end

      # Fetches dietary information for an ingredient and stores results
      # in Ingredient.edamam_results as a jsonb hash. We do this so you
      # can reprocess results without re-hitting the rate limited API.
      #
      # There is a lot of information returned in this. For now we're just
      # using Dietary Restriction informaion. But you could grab other
      # nutrition info. See API docs/examples on Edamam for more info or just
      # browser the stored data.
      #
      # @param [Integer] ingredient_id to populate
      #
      # @example
      #   ApiRecipe::Edamam.fetch_data(Ingredient.first.id)
      def fetch_data(ingredient_id)
        ApiRecipe::Utils.log(name,
                             :fetch_data,
                             { ingredient_id: })
        fetch_ingredient(ingredient_id)
        fetch_dietary(ingredient_id)
      rescue StandardError => e
        ApiRecipe::Utils.log_err(name,
                                 :fetch_data,
                                 e,
                                 { ingredient_id: })
      end

      # Fetches basic ingredient information. Since this is just sample code
      # for an interview it makes the following assumptions:
      #
      # * If you hit Edamam with an incredient like 'chicken' you'll get tons
      #   of options... we just assume the first one is right.
      #
      # This populates Ingredient.edamam_results['parse'] which is required
      # for the Edamam.fetch_dietary call
      #
      # @param [Integer] ingredient_id to populate
      #
      # @example
      #   ApiRecipe::Edamam.fetch_ingredients(Ingredient.first.id)
      def fetch_ingredient(ingredient_id)
        ingredient = Ingredient.find_by_id(ingredient_id)
        # Docs on api for this
        # https://developer.edamam.com/food-database-api-docs
        uri = URI('https://api.edamam.com/api/food-database/v2/parser')
        params = {
          app_id: ENV['EDAMAM_APP_ID'],
          app_key: ENV['EDAMAM_APP_KEY'],
          ingr: ingredient.name.strip.downcase,
          'nutrition-type': 'cooking'
        }
        uri.query = params.to_query

        res = ApiRecipe::Utils.http_get(uri, pause: 2)
        ingredient.edamam_results = {}
        ingredient.edamam_results['parse'] = res
        ingredient.save
        ingredient
      end

      # Fetches dietary information give basic Edamam ingredient information
      # from Edamam.fetch_ingredient call that's stored in
      # Ingredient.edamam_results['parse']
      #
      # This populates Ingredient.edamam_results['nutrients']
      #
      # @param [Integer] ingredient_id to populate
      #
      # @example
      #   ApiRecipe::Edamam.fetch_dietary(Ingredient.first.id)
      def fetch_dietary(ingredient_id)
        ingredient = Ingredient.find_by_id(ingredient_id)
        ingredient.edamam_hints

        uri = URI('https://api.edamam.com/api/food-database/v2/nutrients')
        params = {
          app_id: ENV['EDAMAM_APP_ID'],
          app_key: ENV['EDAMAM_APP_KEY']
        }
        uri.query = params.to_query

        body = ingredient.edamam_ingr_h.to_json # results[:ingr_h].to_json

        res = ApiRecipe::Utils.http_post(uri, body:, pause: 2)
        ingredient.edamam_results['nutrients'] = res
        ingredient.save
        ingredient
      end
    end
  end
end

# frozen_string_literal: true

module ApiRecipe
  class Edamam
    class << self
      def fetch_all_dietary(site_klass: nil)
        arel = Ingredient.where(edamam_results: {})
        arel = arel.where(site_klass:) if site_klass
        arel.find_each do |ing|
          fetch_data(ing.id)
        end
      end

      def fetch_data(ingredient_id)
        puts ''
        puts "Loading nutrition: #{ingredient_id}"
        fetch_ingredient(ingredient_id)
        fetch_dietary(ingredient_id)
      rescue StandardError => e
        puts "Error on ingredient_id: #{ingredient_id}"
        puts e.message
      end

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

      # relies on data being populated in ingredient in fetch_ingredient
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

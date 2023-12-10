# frozen_string_literal: true

module ApiRecipe
  class Edamam
    class << self
      def fetch_all_dietary
        Ingredient.where(edamam_food_id: nil).find_each do |ing|
          fetch_dietary(ing.id)
          sleep 3 # don't exceed api rate limited on Edamam
        end
      end

      def fetch_dietary(ingredient_id)
        ingredient = Ingredient.find_by_id(ingredient_id)
        puts ''
        puts "Loading nutrition: #{ingredient.name}"
        res = fetch_ingredient(ingredient.name)
        ingredient.edamam_food_id = res[:food_id]
        ingredient.edamam_img = res[:img]
        ingredient.edamam_measure_uri = res[:measure_uri]
        ingredient.edamam_nutrition = res
        ingredient.save
      rescue StandardError => e
        puts "Error on ingredient_id: #{ingredient_id}"
        puts e.message
      end

      def fetch_ingredient(ingredient_name)
        # Docs on api for this
        # https://developer.edamam.com/food-database-api-docs

        results = {}

        headers = { 'Accept' => 'application/json' }

        uri = URI('https://api.edamam.com/api/food-database/v2/parser')
        params = {
          app_id: ENV['EDAMAM_APP_ID'],
          app_key: ENV['EDAMAM_APP_KEY'],
          ingr: ingredient_name,
          'nutrition-type': 'cooking'
        }
        uri.query = params.to_query

        puts ''
        puts "Requesting: #{uri}"

        response = Net::HTTP.get_response(uri, headers)
        res = response.read_body
        results[:parse] = res
        data = JSON.parse(res)['hints'].first

        # get nutrients
        results[:food_id] = data['food']['foodId']
        results[:img] = data['food']['image']
        results[:measure_uri] = data['measures'].first['uri']
        results[:ingr_h] = {
          ingredients: [
            {
              quantity: 0,
              measureURI: results[:measure_uri],
              foodId: results[:food_id]
            }
          ]
        }

        uri = URI('https://api.edamam.com/api/food-database/v2/nutrients')
        params = {
          app_id: ENV['EDAMAM_APP_ID'],
          app_key: ENV['EDAMAM_APP_KEY']
        }
        uri.query = params.to_query

        body = results[:ingr_h].to_json

        puts ''
        puts "Requesting: #{uri}"
        puts "Body: #{body}"
        headers['Content-Type'] = 'application/json'
        res = HTTParty.post(uri.to_s, body:, headers:)
        results[:nutrients] = res
        results
      end
    end
  end
end

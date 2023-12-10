# frozen_string_literal: true

# This isn't used... the api didn't work for finding dietary info on
# ingredients. Keeping basics here in case I need to use this later on.
module ApiRecipe
  class Spoontacular
    class << self
      def fetch_ingredient(ingredient_name)
        # Docs on api for this
        # https://spoonacular.com/food-api/docs#Ingredient-Search
        # Intolerances
        # https://spoonacular.com/food-api/docs#Intolerances
        uri = URI('https://api.spoonacular.com/food/ingredients/search')
        params = {
          query: ingredient_name,
          intolerances: 'dairy,egg,gluten,grain,peanut',
          metaInformation: true,
          apiKey: ENV['SPOONTACULAR_API_KEY']
        }
        uri.query = params.to_query

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Get.new(uri.to_s)

        response = http.request(request)
        response.read_body
      end
    end
  end
end

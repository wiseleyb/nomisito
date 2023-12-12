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

      # query: any string, example 'carne asada'
      # ingredients_hash: a hash of true (include), false (exclude),
      #   by ingerdient ids, example:
      #   { 1: true, 3: false }
      # dietary_restriction: array of dietary_id restrictions to exclude:
      #  [1,4,9]
      def search(query,
                 ingredient_options: {},
                 dietary_restrictions: [])
        recipes = []
        res = search_hash(query, ingredient_options:)

        res.each do |recipe|
          r = Recipe.new(recipe['name'])
          recipe['ingredients'].map do |ingr|
            r.ingredients <<
              Ingredient.where(site_klass: name,
                               name: ingr['name'].downcase).first
            r.ingredients_desc << json_ingredient_to_desc(ingr)
          end
          r.ingredients.compact!
          r.steps = recipe['directions']
          recipes << r
        end

        # filter by dietary
        recipes.delete_if do |r|
          r.dietary_blocked?(dietary_restrictions)
        end

        recipes
      end

      def search_hash(query,
                      ingredient_options: {})
        uri = URI('https://guac-is-extra.herokuapp.com')
        params = {
          name: query
        }

        # process ingredients
        excluded = []
        included = []
        ingredient_options.each do |k, v|
          ingr = Ingredient.find_by_id(k)
          excluded << ingr.name if ingr && v == false
          included << ingr.name if ingr && v == true
        end
        included = included.map(&:strip).compact.join(',')
        excluded = excluded.map(&:strip).compact.join(',')
        params[:includeIngredients] = included unless included.blank?
        params[:excludeIngredients] = excluded unless excluded.blank?

        uri.query = params.to_query

        puts ''
        puts "Requesting: #{uri}"

        res = Net::HTTP.get_response(uri)
        JSON.parse(res.body)
      end

      def json_ingredient_to_desc(ingr)
        [
          ingr['quantity'],
          ingr['name'],
          ingr['preparation']
        ].compact.map(&:strip).delete_if(&:blank?).join(', ')
      end
    end
  end
end

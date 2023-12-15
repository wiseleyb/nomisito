# frozen_string_literal: true

module ApiRecipe
  class GuacIsExtra < ApiRecipe::RecipeApiBase
    # Impelements GuacIsExta API
    # API doc: https://github.com/madeintandem/guac-is-extra
    class << self
      # Caches all ingredients in the db from the GuacIsExtra api and populates
      # Ingredient[:name, :site_klass]
      def cache_ingredients
        fetch_ingredients.each do |ing|
          next if ing.to_s.strip.blank?

          log('cache_ingredients', { action: %("Adding #{ing.downcase}") })

          ingr_base.where(name: ing.downcase).first_or_create

          # HACK: to speed up tests
          break if test_break_on_ingreint_limit? && Rails.env.test?
        end
      end

      # Downloads all recipes from GuacIsExtra API
      # TODO: IRL you'd handle paging here
      def fetch_all
        # TODO: While mostly for setup - IRL you should add retry logic
        #       here for http errors
        url = 'https://guac-is-extra.herokuapp.com/'
        ApiRecipe::Utils.http_get(url)
      end

      # Fetches ingredient list from API JSON data
      def fetch_ingredients
        data = fetch_all
        data.map { |recipe| recipe['ingredients'] }
            .map { |rec| rec.map { |ing| ing['name'] } }
            .flatten.uniq.sort
      end

      # Performs a basic search of GuacIsExtra API
      #
      # @param [String, nil] query recipe name to filter on
      # @param [Hash, nil] ingredient_options is a hash of
      # ingredient_ids: [true/false] to include/exclude
      # @param [Array, nil] dietary_restrictions is an array of
      # dietary_ids to limit by
      #
      # @example
      #   ApiRecipe::GuacIsExtra.search('chicken',
      #                                 { 1: true, 2: false },
      #                                 [ 1, 2])
      #
      # @return [Array] of populated Recipe objects
      def search(query,
                 ingredient_options: {},
                 dietary_restrictions: [])
        recipes = []
        res = search_hash(query)
        res.each do |recipe|
          r = Recipe.new(recipe['name'], name)
          recipe['ingredients'].map do |ingr|
            r.ingredients <<
              ingr_base.where(name: ingr['name'].downcase).first
            r.ingredients_desc << json_ingredient_to_desc(ingr)
          end
          r.ingredients.compact!
          r.steps = recipe['directions']
          recipes << r
        end

        Recipes.filter_recipes_by_ingredients(recipes, ingredient_options)
        Recipes.filter_by_dietary(recipes, dietary_restrictions)
        # filter by dietary
        recipes.delete_if do |r|
          r.dietary_blocked?(dietary_restrictions)
        end

        recipes
      end

      # Gets recipe-name search results from GuacIsExtra. This doesn't use the
      # APIs ingredient include/exclude options because this is pretty
      # inconsistent across various APIs and it was simpler to just do after
      # search
      #
      # @param [String, nil] query recipe name to filter on
      def search_hash(query)
        uri = URI('https://guac-is-extra.herokuapp.com')
        params = { name: query }
        uri.query = params.to_query
        ApiRecipe::Utils.http_get(uri)
      end

      # @deprecated This is inconsitent (AND vs OR) or not available in many
      # apis... so we just ignore this API feature and do this post search.
      # You could optimize and do this via API but it'd add a lot of
      # compliexity. This also allows and/or options... for example it seems
      # logical to want all excluded ingredients but maybe 1 or more included
      # ingredients. Right now this is just AND
      def filter_ingredients(params, ingredient_options: {})
        # process ingredients
        excluded = []
        included = []
        ingredient_options.each do |k, v|
          ingr = ingr_base.find_by_id(k)
          excluded << ingr.name if ingr && v == false
          included << ingr.name if ingr && v == true
        end
        included = included.map(&:strip).compact.join(',')
        excluded = excluded.map(&:strip).compact.join(',')
        params[:includeIngredients] = included unless included.blank?
        params[:excludeIngredients] = excluded unless excluded.blank?
        params
      end

      # Converts json ingredient details to a readable string
      def json_ingredient_to_desc(ingr)
        [
          ingr['quantity'],
          ingr['name'],
          ingr['preparation']
        ].compact.map(&:strip).delete_if(&:blank?).join(', ')
      end

      # Hint text to display in UI for recipe-name search box
      def text_input_hint
        'leave blank to find all recipes'
      end

      # Helper method for logging
      #
      # @param [String] method name of what's being logged
      # @param [Hash, nil] data  hash of other params to log
      #
      # @example
      #   ApiRecipe::GuacIsExtra.log('search', { query: 'chicken' })
      #   Would log something like
      #     source=ApiRecipe::GuacIsExtra method=search query=chicken
      def log(method, data = {})
        ApiRecipe::Utils.log(name, method, data)
      end
    end
  end
end

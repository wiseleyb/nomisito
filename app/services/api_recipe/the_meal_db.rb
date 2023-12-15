# frozen_string_literal: true

# TODO: The data returned has images, links to the recipe
# TODO: We're just doing the first page - this api has paging though
# TODO: The paid version of this api allows you to filter by multiple ingredients
module ApiRecipe
  # Impelements TheMealDb API
  # API doc: https://www.themealdb.com/api.php
  class TheMealDb < ApiRecipe::RecipeApiBase
    class << self
      # Caches all ingredients in the db from the TheMealDb api and populates
      # Ingredient[:name, :site_klass]
      def cache_ingredients
        fetch_ingredients.sort.each_with_index do |ing, _idx|
          next if ing.to_s.strip.blank?

          ApiRecipe::Utils.log(name,
                               :cache_ingredients,
                               { adding: ing.downcase })
          ingr_base.where(name: ing.downcase).first_or_create

          # HACK: to speed up tests
          break if Rails.env.test? && ingr_base.count >= test_ingredient_limit
        end
      end

      # Downloads all recipes from TheMealDb API
      #
      # @param [String] letter to download recipes for
      def fetch_all(letter)
        url = "https://www.themealdb.com/api/json/v1/1/search.php?f=#{letter}"
        ApiRecipe::Utils.http_get(url)
      end

      # Fetches ingredient list from API JSON data
      def fetch_ingredients
        res = []
        ('a'..'z').to_a.each do |letter|
          data = fetch_all(letter)
          Array(data['meals']).each do |recipe|
            recipe.each do |k, v|
              res << v.strip if k.to_s.starts_with?('strIngredient') && v.present?
            end
          end

          # HACK: to speed up tests
          break if test_break_on_ingreint_limit? && Rails.env.test?
        end
        res.flatten.delete_if { |r| r.to_s.strip.blank? }.uniq.sort
      end

      # Performs a basic search of TheMealDb API
      #
      # @param [String, nil] query recipe name to filter on
      # @param [Hash, nil] ingredient_options is a hash of
      # ingredient_ids: [true/false] to include/exclude
      # @param [Array, nil] dietary_restrictions is an array of
      # dietary_ids to limit by
      #
      # @example
      #   ApiRecipe::TheMealDb.search('chicken',
      #                               { 1: true, 2: false },
      #                               [ 1, 2])
      #
      # @return [Array] of populated Recipe objects
      def search(query,
                 ingredient_options: {},
                 dietary_restrictions: [])
        recipes = []
        url = "https://www.themealdb.com/api/json/v1/1/search.php?s=#{query}"
        res = ApiRecipe::Utils.http_get(url)

        res['meals'].each do |r|
          recipe = Recipe.new(r['strMeal'], name)

          ingredients =
            r.select { |k, v| k.starts_with?('strIngredient') && v.present? }
          ingredients.each do |k, v|
            ingr = ingr_base.where(name: v.downcase.strip).first
            if ingr
              inum = k.gsub('strIngredient', '')
              measure = r["strMeasure#{inum}"]
              recipe.ingredients << ingr
              recipe.ingredients_desc << "#{measure} #{ingr.name}"
            else
              recipe.ingredients_desc << "Missing ingredient #{k}:#{v} in db"
            end
          end
          recipe.steps = r['strInstructions'].split("\r\n")
          recipes << recipe
        end

        Recipes.filter_recipes_by_ingredients(recipes, ingredient_options)
        Recipes.filter_by_dietary(recipes, dietary_restrictions)

        recipes
      end

      # Hint text to display in UI for recipe-name search box
      def text_input_hint
        'must enter 1 character'
      end
    end
  end
end

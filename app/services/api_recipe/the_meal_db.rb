# frozen_string_literal: true

# TODO: The data returned has images, links to the recipe
# TODO: We're just doing the first page - this api has paging though
# TODO: The paid version of this api allows you to filter by multiple ingredients
module ApiRecipe
  class TheMealDb
    class << self
      def cache_ingredients
        fetch_ingredients.sort.each do |ing|
          next if ing.to_s.strip.blank?

          puts "Adding: #{ing.downcase}"
          ingr_base.where(name: ing.downcase).first_or_create
        end
      end

      def reset_cache!
        ingr_base.destroy_all
      end

      # Fetches ingredient list from all configured recipe urls
      def fetch_ingredients
        # TODO: This should accomodate bad data
        res = []
        ('a'..'z').to_a.each do |letter|
          data = fetch_all(letter)
          Array(data['meals']).each do |recipe|
            recipe.each do |k, v|
              res << v.strip if k.to_s.starts_with?('strIngredient') && v.present?
            end
          end
        end
        res.flatten.delete_if { |r| r.to_s.strip.blank? }.uniq.sort
      end

      def fetch_all(letter)
        url = "https://www.themealdb.com/api/json/v1/1/search.php?f=#{letter}"
        ApiRecipe::Utils.http_get(url)
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
        url = "https://www.themealdb.com/api/json/v1/1/search.php?s=#{query}"
        res = ApiRecipe::Utils.http_get(url)

        res['meals'].each do |r|
          recipe = Recipe.new(r['strMeal'], name)

          ingredients =
            r.select { |k, v| k.starts_with?('strIngredient') && v.present? }
          ingredients.each do |k, v|
            inum = k.gsub('strIngredient', '')
            ingr = ingr_base.where(name: v.downcase.strip).first
            measure = r["strMeasure#{inum}"]
            recipe.ingredients << ingr
            recipe.ingredients_desc << "#{measure} #{ingr.name}"
          end
          recipe.steps = r['strInstructions'].split("\r\n")
          recipes << recipe
        end

        # filter by dietary
        recipes.delete_if do |r|
          r.dietary_blocked?(dietary_restrictions)
        end

        filter_recipes_by_ingredients(recipes, ingredient_options)

        recipes
      end

      def filter_recipes_by_ingredients(recipes, ingredient_options)
        keep_ingredient_names =
          Ingredient.where(id: ingredient_options.select { |_k, v| v == true }
                                                 .keys)
                    .map(&:name).map(&:downcase)
        discard_ingredient_names =
          Ingredient.where(id: ingredient_options.select { |_k, v| v == false }
                                                 .keys)
                    .map(&:name).map(&:downcase)

        recipes.delete_if do |r|
          ingredient_names = r.ingredients.map(&:name).map(&:downcase)
          res =
            # check for required ingredients
            ((ingredient_names & keep_ingredient_names).size !=
             keep_ingredient_names.size) ||
            # check for blocked ingredients
            (ingredient_names & discard_ingredient_names).size.positive?

          res
        end
      end

      def ingr_base
        Ingredient.where(site_klass: name)
      end

      def text_input_hint
        'must enter 1 character'
      end
    end
  end
end

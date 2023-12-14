# frozen_string_literal: true

require 'net/http'

# Utility class to manage loading/filter recipes
class Recipes
  # NOTE: store as string to prevent initialization/caching issues
  RECIPE_KLASSES = %w[ApiRecipe::GuacIsExtra ApiRecipe::TheMealDb].freeze

  class << self
    # If you're deploying or downloading for dev, this will initialize
    # data from all recipe APIs. This can be slow
    def initial_setup!
      RECIPE_KLASSES.each do |rk|
        # load ingredients
        ApiRecipe::Utils.log(name, :setup!, { loading: rk })
        klass = rk.constantize
        klass.reset_cache!
        klass.cache_ingredients
        ApiRecipe::Utils.log(
          name,
          :setup!,
          { ingredients_loaded: Ingredient.where(site_klass: rk).count }
        )

        # load dietary restriction data
        ApiRecipe::Utils.log(name, :setup!, { loading_dietary: rk })
        ApiRecipe::Edamam.fetch_all_dietary(site_klass: rk)
        Dietary.reset!(site_klass: rk)
        ApiRecipe::Utils.log(
          name,
          :setup!,
          { dietary_loaded: Dietary.where(site_klass: rk).count }
        )
      end
    end

    # Filter recipes by included/excluded ingredients
    #
    # While some APIs allow you to filter this in the API it's inconsitent
    # Some are OR, some are AND... for simplicity just ignore this and post
    # filter.
    #
    # @param [Array(Recipe)] recipes to analyze
    # @param [Hash, nil] ingredient_options is a hash of
    # ingredient_ids: [true/false] to include/exclude
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

    # Filter recipes by dietary restrictions
    #
    # @param [Array(Recipe)] recipes to analyze
    # @param [Array, nil] dietary_restrictions is an array of
    # dietary_ids to limit by
    def filter_by_dietary(recipes, dietary_restrictions)
      recipes.delete_if do |r|
        r.dietary_blocked?(dietary_restrictions)
      end
    end
  end
end

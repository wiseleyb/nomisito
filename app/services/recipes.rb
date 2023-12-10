# frozen_string_literal: true

require 'net/http'

class Recipes
  # NOTE: store as string to prevent initialization/caching issues
  RECIPE_KLASSES = %w[ApiRecipe::GuacIsExtra].freeze

  class << self
    def cache_ingredients
      # TODO: If this was some million ingredient list you'd batch this up
      RECIPE_KLASSES.each do |rk|
        klass = rk.constantize
        klass.cache_ingredients
      end
      puts "Igredients loaded: #{Ingerdient.count}"
    end

    def reset_ingredients!
      RECIPE_KLASSES.each do |rk|
        klass = rk.constantize
        klass.reset_cache!
      end
    end
  end
end

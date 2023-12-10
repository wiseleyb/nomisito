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
        klass.fetch_ingredients.each do |ing|
          next if ing.to_s.strip.blank?

          puts "Adding: #{ing.downcase}"
          Ingredient.where(name: ing.downcase).first_or_create
        end
      end
    end

    def reset_ingredients!
      Ingredient.destroy_all
    end
  end
end

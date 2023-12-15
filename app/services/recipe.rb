# frozen_string_literal: true

# Basic data structure for all recipes
#
# When we download various API recipes we convert them to this for basic
# filterting, UI display, etc.
class Recipe
  # @return [String] name of recipe
  attr_accessor :name
  # @return [Array(Ingredient)] ingredients in recipe
  attr_accessor :ingredients
  attr_accessor :ingredients_desc, :site_klass, :steps

  def initialize(name,
                 site_klass,
                 ingredients: [],
                 ingredient_desc: [],
                 steps: [])
    @name = name.strip
    @site_klass = site_klass
    @ingredients = Array(ingredients).compact
    @ingredients_desc = Array(ingredient_desc).compact
    @steps = Array(steps)
  end

  def dietary_blocked?(dietary_restrictions)
    restrictions =
      Dietary.where(site_klass:,
                    id: dietary_restrictions).map(&:name).map(&:downcase)
    return false unless restrictions.present?

    ingredients.each do |ingr|
      if (ingr.dietary_restrictions.map(&:downcase) & restrictions).size ==
         restrictions.size
        next
      end

      return true
    end
    false
  end

  def allowed_dietary_restrictions
    ingredients.map(&:dietary_restrictions).reduce { |a, b| a & b }
  end
end

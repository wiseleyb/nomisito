# frozen_string_literal: true

class Recipe
  attr_accessor :name,
                :ingredients,
                :ingredients_desc,
                :steps

  def initialize(name, ingredients: [], ingredient_desc: [], steps: [])
    @name = name
    @ingredients = Array(ingredients).compact
    @ingredients_desc = Array(ingredient_desc).compact
    @steps = Array(steps)
  end

  def dietary_blocked?(dietary_restrictions)
    restrictions =
      Dietary.where(id: dietary_restrictions).map(&:name).map(&:downcase)
    return false unless restrictions.present?

    ingredients.each do |ingr|
      next if (ingr.dietary_restrictions.map(&:downcase) & restrictions).present?

      return true
    end
    false
  end

  def dietary_restrictions
    ingredients.map(&:dietary_restrictions).reduce { |a, b| a & b }
  end

  def debug
    puts ''
    puts '-' * 80
    puts [
      @name,
      "\nIngredients:",
      @ingredients_desc.join("\n"),
      "\nSteps:",
      @steps.join("\n")
    ].join("\n")
  end
end

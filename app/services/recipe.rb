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
    drestrictions = Array(dietary_restrictions).map(&:downcase)

    ingredients.each do |ingr|
      drs = ingr.dietary_restrictions.map(&:downcase)
      drestrictions.each do |dr|
        return true unless drs.include?(dr.downcase)
      end
    end
    false
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

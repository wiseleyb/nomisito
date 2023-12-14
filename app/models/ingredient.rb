# frozen_string_literal: true

class Ingredient < ApplicationRecord
  include IngredientEdamamHelper

  # Parses dietary restrictions names out of cached Ingredient.edamam_results
  def dietary_restrictions
    edamam_health_labels
  end
end

# frozen_string_literal: true

class Ingredient < ApplicationRecord
  include IngredientEdamamHelper

  def dietary_restrictions
    edamam_health_labels
  end
end

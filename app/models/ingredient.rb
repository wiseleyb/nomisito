# frozen_string_literal: true

class Ingredient < ApplicationRecord
  include IngredientEdamamHelper

  def dietary_restrictions
    edamam_results['nutrients']['healthLabels'].compact
  end
end

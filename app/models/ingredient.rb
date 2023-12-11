# frozen_string_literal: true

class Ingredient < ApplicationRecord
  def dietary_restrictions
    edamam_nutrition['nutrients']['healthLabels'].compact
  end
end

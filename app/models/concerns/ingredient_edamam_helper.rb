# frozen_string_literal: true

#--------------------------------------------------
# Cache Edamam API results in DB
#
# https://developer.edamam.com/
#
# Since Edamam is heavily rate limited this allows
# us to debug, improve, etc without having to hit
# the API again
#
# # TODO: Not handling nils well here
#--------------------------------------------------
module IngredientEdamamHelper
  # food id in edamam
  def edamam_food_id
    edamam_hints.try(:[], 'food')
                .try(:[], 'foodId')
  end

  # image associated with ingredient
  def edamam_img
    edamam_hints.try(:[], 'food')
                .try(:[], 'image')
  end

  # measure uri used to look up nutrient info
  def edamam_measure_uri
    edamam_hints.try(:[], 'measures')
                .first
                .try(:[], 'uri')
  end

  def edamam_hints
    edamam_results.try(:[], 'parse')
                  .try(:[], 'hints')
                  .first
  end

  # hash used for dietary restrictions look up
  def edamam_ingr_h
    {
      ingredients: [
        {
          quantity: 0,
          measureURI: edamam_measure_uri,
          foodId: edamam_food_id
        }
      ]
    }
  end
end

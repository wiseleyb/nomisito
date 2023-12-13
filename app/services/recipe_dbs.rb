# frozen_string_literal: true

class RecipeDbs
  attr_accessor :name, :klass

  def initialize(name, klass)
    @name = name
    @klass = klass
  end

  def self.klasses
    [
      RecipeDbs.new('Guac Is Extra', 'ApiRecipe::GuacIsExtra'),
      RecipeDbs.new('The Meal DB', 'ApiRecipe::TheMealDb')
    ]
  end
end

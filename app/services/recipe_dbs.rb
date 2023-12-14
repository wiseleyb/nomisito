# frozen_string_literal: true

# Simple class to hold api classes to search against
class RecipeDbs
  attr_accessor :name, :klass

  # @param [String] name (human readable) of the class
  # @param [String] klass name
  def initialize(name, klass)
    @name = name
    @klass = klass
  end

  # @return [Array(RecipeDbs)] for use in select boxes
  def self.klasses
    [
      RecipeDbs.new('Guac Is Extra', 'ApiRecipe::GuacIsExtra'),
      RecipeDbs.new('The Meal DB', 'ApiRecipe::TheMealDb')
    ]
  end
end

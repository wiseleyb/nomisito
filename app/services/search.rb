# frozen_string_literal: true

# Simple search abstraction for various recipe apis
class Search
  attr_accessor :klass

  # @param [String] site_klass to be searched
  def initialize(site_klass = 'ApiRecipe::GuacIsExtra')
    @klass = site_klass.constantize
  end

  # Search for recipes
  # @param [String, nil] query of recipe name to search for
  # @param [Hash, nil] ingredient_options is a hash of
  # ingredient_ids: [true/false] to include/exclude
  # @param [Array, nil] dietary_restrictions is an array of
  # dietary_ids to limit by
  #
  # @return [Array(Recipe)] returns array of recipes filtered by inputs
  def search(query = '', ingredient_options: {}, dietary_restrictions: [])
    @klass.search(query, ingredient_options:, dietary_restrictions:)
  end
end

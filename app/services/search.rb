# frozen_string_literal: true

class Search
  attr_accessor :klass

  def initialize(site_klass = 'ApiRecipe::GuacIsExtra')
    @klass = site_klass.constantize
  end

  def search(query, ingredient_options: {}, dietary_restrictions: [])
    # NOTE: this can be done more efficiently in the latest version of ruby
    @klass.search(query, ingredient_options:, dietary_restrictions:)
  end
end

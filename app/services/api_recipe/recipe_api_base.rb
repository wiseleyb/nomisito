# frozen_string_literal: true

module ApiRecipe
  # "Interface" for recipe-apis. Ruby doesn't really do interfaces well but, if
  # they did this would be a template of what you're required to support in
  # classes like GuacIsExtra and TheMealDb
  class RecipeApiBase
    class << self
      # Should download all ingredients from the recipe api and populate
      # Ingredient[:name, :site_klass]
      def cache_ingredients
        raise 'Class must implement'
      end

      # Should implement search of the recipe API
      #
      # @param [String, nil] _query recipe name to filter on
      # @param [Hash, nil] _ingredient_options is a hash of
      # ingredient_ids: [true/false] to include/exclude
      # @param [Array, nil] _dietary_restrictions is an array of
      # dietary_ids to limit by
      #
      # @example
      #   ApiRecipe::GuacIsExtra.search('chicken',
      #                                 { 1: true, 2: false },
      #                                 [ 1, 2])
      # @return [Array] of populated Recipe objects
      def search(_query,
                 _ingredient_options: {},
                 _dietary_restrictions: [])
        raise 'Class must implement'
      end

      # Deletes all ingredients for ingr_base site_klass scope
      def reset_cache!
        ingr_base.destroy_all
      end

      # Scopes DB calls to ingredients to this site_klass. Example site_klasses
      # would be GuacIsExtra, TheMealDb, etc.
      def ingr_base
        Ingredient.where(site_klass: name)
      end

      # Text used in UI search box as hint
      def text_input_hint
        'enter recipe name'
      end

      # Used to limit number of ingredients pre-cached in test to speed
      # things up
      def test_ingredient_limit
        5
      end

      # User to limit number of ingredients in test
      def test_break_on_ingreint_limit?
        @test_ingr_limit ||= 0
        @test_ingr_limit += 1
        @test_ingr_limit >= test_ingredient_limit
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiRecipe::GuacIsExtra, type: :service do
  let(:subject) { ApiRecipe::GuacIsExtra }
  let(:site_klass) { subject.name }
  let(:vcr_base) { 'guac' }

  context '#ingr_base' do
    let!(:ingr_guac) do
      create(:ingredient, name: 'salt', site_klass:)
    end
    let!(:ingr_mealdb) do
      create(:ingredient, name: 'salt', site_klass: 'ApiRecipe::TheMealDb')
    end

    it 'filters on site_klass' do
      expect(Ingredient.count).to eq(2)
      expect(subject.ingr_base.count).to eq(1)
      expect(subject.ingr_base.first.site_klass).to eq(subject.name)
    end
  end

  context '#cache_ingredients' do
    # TODO: this is happy path - IRL we'd test stuff like the site being down
    it 'loads ingredients from guac-is-extra site' do
      VCR.use_cassette('guac-is-extra-ingredients') do
        subject.cache_ingredients
        expect(Ingredient.count).to eq(subject.test_ingredient_limit)
        expect(subject.ingr_base.count).to eq(subject.test_ingredient_limit)
      end
    end
  end

  context '#search' do
    before do
      # Mock out API limit delay to speed up initial runs of VCR
      # Becareful with this as specs grow. Edamam has a rate limit of 35/min
      allow(ApiRecipe::Utils).to receive(:delay)
    end

    let!(:ingr_beef) do
      create(:ingredient, name: 'ground beef',
                          site_klass:)
    end
    let!(:ingr_flour) do
      create(:ingredient, name: 'all-purpose flour',
                          site_klass:)
    end

    # In TDD you should  break this into smaller tests
    # Working with external APIs with rate limits, etc
    # though makes this a lot slower and complicated
    # For this eval I just combined a few basic search tests into
    # one test for simplicity
    it 'finds by recipes' do
      VCR.use_cassette("#{vcr_base}-search") do
        # load ingredient data
        ApiRecipe::Edamam.fetch_data(ingr_beef.id)
        expect(ingr_beef.reload.dietary_restrictions).to \
          include('PALEO')
        expect(ingr_beef.reload.dietary_restrictions).to_not \
          include('VEGETARARIAN')

        # load ingredient data
        ApiRecipe::Edamam.fetch_data(ingr_flour.id)
        expect(ingr_flour.reload.dietary_restrictions).to \
          include('VEGETARIAN')
        ApiRecipe::Edamam.fetch_data(ingr_flour.id)
        expect(ingr_flour.reload.dietary_restrictions).to_not \
          include('GLUTEN_FREE')

        # build Dietary table - confirms Dietary Restrictions were loaded from
        # Edamam
        Dietary.reset!(site_klass:)
        diets = Dietary.all.map(&:name)
        expect(diets).to include('PALEO')
        expect(diets).to include('VEGETARIAN')
        expect(diets).to include('GLUTEN_FREE')

        # search by ingredient
        recipes =
          subject.search('', ingredient_options: { ingr_beef.id.to_s => true })
        expect(recipes.map(&:name)).to include('Double Decker Tacos')
        expect(recipes.map(&:name)).to_not include('Fish Tacos')

        # search by excluded ingredient
        recipes =
          subject.search('', ingredient_options: { ingr_beef.id.to_s => false })
        expect(recipes.map(&:name)).to include('Fish Tacos')
        expect(recipes.map(&:name)).to_not include('Double Decker Tacos')

        # search by dietary restriction
        dr = Dietary.where(site_klass:, name: 'PESCATARIAN').first
        recipes = subject.search('', dietary_restrictions: [dr.id])
        expect(recipes.map(&:name)).to include('Fish Tacos')
        expect(recipes.map(&:name)).to_not include('Double Decker Tacos')

        # search by name
        recipes = subject.search('fish')
        expect(recipes.size).to eq(1)
        expect(recipes.map(&:name)).to include('Fish Tacos')

        # search by dietary restriction and included ingredient
        dr = Dietary.where(site_klass:, name: 'PESCATARIAN').first
        recipes =
          subject.search('',
                         ingredient_options: { ingr_flour.id.to_s => true },
                         dietary_restrictions: [dr.id])
        expect(recipes.size).to eq(1)
        expect(recipes.map(&:name)).to include('Fish Tacos')

        # search by dietary restriction and excluded ingredient
        dr = Dietary.where(site_klass:, name: 'PESCATARIAN').first
        recipes =
          subject.search('',
                         ingredient_options: { ingr_flour.id.to_s => false },
                         dietary_restrictions: [dr.id])
        expect(recipes.map(&:name)).to include('Lobster Tacos')
        expect(recipes.map(&:name)).to_not include('Fish Tacos')

        # search by dietary, excluded ingredient and name
        dr = Dietary.where(site_klass:, name: 'PESCATARIAN').first
        recipes =
          subject.search('lobster',
                         ingredient_options: { ingr_flour.id.to_s => false },
                         dietary_restrictions: [dr.id])
        expect(recipes.size).to eq(1)
        expect(recipes.map(&:name)).to include('Lobster Tacos')
      end
    end
  end
end

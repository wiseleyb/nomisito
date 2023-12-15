# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiRecipe::TheMealDb, type: :service do
  let(:subject) { ApiRecipe::TheMealDb }
  let(:site_klass) { subject.name }
  let(:vcr_base) { 'the-meal-db' }

  context '#ingr_base' do
    let!(:ingr_guac) do
      create(:ingredient, name: 'salt', site_klass: subject.name)
    end
    let!(:ingr_mealdb) do
      create(:ingredient, name: 'salt', site_klass: 'ApiRecipe::GuacIsExtra')
    end

    it 'filters on site_klass' do
      expect(Ingredient.count).to eq(2)
      expect(subject.ingr_base.count).to eq(1)
      expect(subject.ingr_base.first.site_klass).to eq(subject.name)
    end
  end

  context '#cache_ingredients' do
    # TODO: this is happy path - IRL we'd test stuff like the site being down
    it 'loads ingredients from api site' do
      VCR.use_cassette("#{vcr_base}-ingredients") do
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

    let!(:ingr_duck) do
      create(:ingredient, name: 'duck legs',
                          site_klass:)
    end
    let!(:ingr_cumin) do
      create(:ingredient, name: 'cumin',
                          site_klass:)
    end
    let!(:ingr_chicken) do
      create(:ingredient, name: 'chicken legs',
                          site_klass:)
    end
    let!(:q) { 'c' }

    # In TDD you should  break this into smaller tests
    # Working with external APIs with rate limits, etc
    # though makes this a lot slower and complicated
    # For this eval I just combined a few basic search tests into
    # one test for simplicity
    it 'finds by recipes' do
      VCR.use_cassette("#{vcr_base}-search") do
        Ingredient.all.each do |ingr|
          ApiRecipe::Edamam.fetch_data(ingr.id)
          ApiRecipe::Edamam.fetch_data(ingr.id)
        end

        # duck test
        expect(ingr_duck.reload.dietary_restrictions).to \
          include('PALEO')
        expect(ingr_duck.reload.dietary_restrictions).to_not \
          include('VEGETARARIAN')

        # cumin test
        expect(ingr_cumin.reload.dietary_restrictions).to \
          include('VEGETARIAN')

        # build Dietary table - confirms Dietary Restrictions were loaded from
        # Edamam
        Dietary.reset!(site_klass:)
        diets = Dietary.all.map(&:name)
        expect(diets).to include('PALEO')
        expect(diets).to include('VEGETARIAN')

        # search by ingredient
        recipes =
          subject.search(q, ingredient_options: { ingr_duck.id.to_s => true })
        expect(recipes.map(&:name)).to include('Duck Confit')
        expect(recipes.map(&:name)).to_not include('Chakchouka')

        # search by excluded ingredient
        recipes =
          subject.search(q, ingredient_options: { ingr_cumin.id.to_s => false })
        expect(recipes.map(&:name)).to include('Duck Confit')
        expect(recipes.map(&:name)).to_not include('Chakchouka')

        # search by dietary restriction
        dr = Dietary.where(site_klass:, name: 'VEGETARIAN').first
        recipes = subject.search('ch', dietary_restrictions: [dr.id])
        expect(recipes.map(&:name)).to include('Chakchouka')
        expect(recipes.map(&:name)).to_not include('Chicken Marengo')

        # search by name
        recipes = subject.search('duck')
        expect(!recipes.empty?).to be_truthy
        expect(recipes.map(&:name)).to include('Duck Confit')

        # search by dietary restriction and included ingredient
        dr = Dietary.where(site_klass:, name: 'VEGETARIAN').first
        recipes =
          subject.search(q,
                         ingredient_options: { ingr_cumin.id.to_s => true },
                         dietary_restrictions: [dr.id])
        expect(!recipes.empty?).to be_truthy
        expect(recipes.map(&:name)).to include('Chakchouka')

        # search by dietary restriction and excluded ingredient
        dr = Dietary.where(site_klass:, name: 'VEGETARIAN').first
        recipes =
          subject.search(q,
                         ingredient_options: { ingr_duck.id.to_s => false },
                         dietary_restrictions: [dr.id])
        expect(recipes.map(&:name)).to include('Chakchouka')
        expect(recipes.map(&:name)).to_not include('Duck Confit')
      end
    end
  end
end

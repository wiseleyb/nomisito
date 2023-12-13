# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiRecipe::Edamam, type: :service do
  context '#fetch_data' do
    let!(:ingredient) do
      create(:ingredient,
             name: '(7 inch) flour tortillas',
             site_klass: 'ApiRecipe::GuacIsExtra')
    end

    it 'loads Edamam data for ingredient' do
      VCR.use_cassette('edamam-ingredient-flour-tortilla') do
        ApiRecipe::Edamam.fetch_data(ingredient.id)
        expect(ingredient.reload.dietary_restrictions).to \
          include('PEANUT_FREE')
      end
    end
  end
end

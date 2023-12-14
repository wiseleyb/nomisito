# frozen_string_literal: true

require 'rails_helper'

# Super basic spec - this is tested better elsewhere
# in a real app this would be tested here as well
RSpec.describe Recipe, type: :service do
  let(:ingr_beans) do
    create(:ingredient,
           name: 'coffee beans',
           site_klass: 'ApiRecipe::Recipes')
  end
  let(:ingr_water) do
    create(:ingredient,
           name: 'water',
           site_klass: 'ApiRecipe::Recipes')
  end

  it 'works' do
    r = Recipe.new('coffee',
                   'ApiRecipe::Recipes',
                   ingredients: [ingr_beans, ingr_water],
                   ingredient_desc: [
                     "1/4 c #{ingr_beans.name}, ground",
                     "2 c #{ingr_water}, boiling"
                   ],
                   steps: [
                     'Steap beans in water for 2 minutes, strain',
                     'Warn morons that it is hot',
                     'Serve'
                   ])
    expect(r.name).to eq('coffee')
    expect(r.site_klass).to eq('ApiRecipe::Recipes')
    expect(r.ingredients).to eq([ingr_beans, ingr_water])
    expect(r.ingredients_desc).to \
      eq(["1/4 c #{ingr_beans.name}, ground",
          "2 c #{ingr_water}, boiling"])
    expect(r.steps).to \
      eq(['Steap beans in water for 2 minutes, strain',
          'Warn morons that it is hot',
          'Serve'])
  end
end

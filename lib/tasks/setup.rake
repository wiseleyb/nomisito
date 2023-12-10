# frozen_string_literal: true

namespace :setup do
  # Sets up data for new site
  desc 'Reset!'
  task reset: :environment do
    Recipes.reset_ingredients!
    Recipes.cache_ingredients
  end
end

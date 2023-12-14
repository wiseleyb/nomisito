# frozen_string_literal: true

namespace :setup do
  # Sets up data for new site
  desc 'Reset!'
  task reset: :environment do
    Recipes.initial_setup!
  end
end

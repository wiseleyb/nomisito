# frozen_string_literal: true

FactoryBot.define do
  factory :ingredient do
    name { FFaker::Name.name }
    site_klass { 'ApiRecipe::GuacIsExtra' }
  end
end

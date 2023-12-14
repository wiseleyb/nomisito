# frozen_string_literal: true

# Holds dietary restrictions for filtering/ui
class Dietary < ApplicationRecord
  # Resets Dietary table and loads/parses ingredient data
  # Should be run when new ingredients are added and run through Edamam
  #
  # @param [String, nil] site_klass to filter by
  def self.reset!(site_klass: nil)
    ingr_arel = Ingredient
    ingr_arel = ingr_arel.where(site_klass:) if site_klass
    diet_arel = Dietary
    diet_arel = diet_arel.where(site_klass:) if site_klass

    # reset table
    diet_arel.destroy_all
    vals = {}

    # get all dietary restrictions
    ingr_arel.find_each do |ing|
      vals[ing.site_klass] ||= []
      vals[ing.site_klass] << ing.dietary_restrictions
    end

    # unique and insert into table
    vals.each_key do |k|
      vals[k] = vals[k].flatten.uniq.compact.sort
      vals[k].each do |d|
        diet_arel.where(name: d, site_klass: k).first_or_create
      end
    end
    vals
  end
end

# frozen_string_literal: true

class Dietary < ApplicationRecord
  def self.reset!
    # reset table
    Dietary.destroy_all
    vals = {}

    # get all dietary restrictions
    Ingredient.find_each do |ing|
      vals[ing.site_klass] ||= []
      vals[ing.site_klass] << ing.dietary_restrictions
    end

    # unique and insert into table
    vals.each_key do |k|
      vals[k] = vals[k].flatten.uniq.compact.map(&:titleize).sort
      vals[k].each do |d|
        Dietary.where(name: d, site_klass: k).first_or_create
      end
    end
    vals
  end
end

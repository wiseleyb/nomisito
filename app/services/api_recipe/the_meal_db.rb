# frozen_string_literal: true

module ApiRecipe
  class TheMealDb
    class << self
      # Fetches ingredient list from all configured recipe urls
      def fetch_ingredients
        # TODO: This should accomodate bad data
        res = []
        ('a'..'c').to_a.each do |letter|
          data = fetch_all(letter)
          data['meals'].each do |recipe|
            recipe.each do |k, v|
              res << v.strip if k.to_s.starts_with?('strIngredient') && v.present?
            end
          end
        end
        res.flatten.delete_if { |r| r.to_s.strip.blank? }.uniq.sort
      end

      def fetch_all(letter)
        # TODO: While mostly for setup - IRL you should add retry logic
        #       here for http errors
        url = "https://www.themealdb.com/api/json/v1/1/search.php?f=#{letter}"
        puts "Fetching #{url}"
        resp = Net::HTTP.get_response(URI.parse(url))
        data = resp.body
        JSON.parse(data)
      end
    end
  end
end

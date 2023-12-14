# frozen_string_literal: true

# Very basic site controller
class HomeController < ApplicationController
  # Very basic site search page
  def index
    session[:site_klass] = params[:site_klass] if params[:site_klass]
    session[:site_klass] ||= 'ApiRecipe::GuacIsExtra'

    return unless params[:query]

    io = {}
    Array(params[:included]).each { |p| io[p] = true }
    Array(params[:excluded]).each { |p| io[p] = false }

    @recipes = Search.new(session[:site_klass])
                     .search(params[:query],
                             ingredient_options: io,
                             dietary_restrictions: Array(params[:dietary]))
  end
end

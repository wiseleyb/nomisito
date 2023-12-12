# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return unless params[:query]

    io = {}
    Array(params[:included]).each { |p| io[p] = true }
    Array(params[:excluded]).each { |p| io[p] = false }

    @recipes = Search.new.search(params[:query],
                                 ingredient_options: io,
                                 dietary_restrictions: Array(params[:dietary]))
  end
end

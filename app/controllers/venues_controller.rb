class VenuesController < ApplicationController
  def map
    @venues = Venue.all
    respond_to do |format|
      format.html
      format.json { render :json => @venues }
    end
  end

  def index
    @venues = Venue.all.order(:title)
  end

  def show
    @venue = Venue.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render :json => @venue.to_json(include: :events) }
    end
  end
end

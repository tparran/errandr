require 'open-uri'

class ItemsController < ApplicationController
  def index
    @items = Item.all
  end

  def show
    @item = Item.find(params[:id])
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new
    @item.user_id = params[:user_id]
    @item.price = params[:price]
    @item.image = params[:image]
    @item.url = params[:url]
    @item.name = params[:name]

    if @item.save
      redirect_to "/items", :notice => "Item created successfully."
    else
      render 'new'
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])

    @item.user_id = params[:user_id]
    @item.price = params[:price]
    @item.image = params[:image]
    @item.url = params[:url]
    @item.name = params[:name]

    if @item.save
      redirect_to "/items", :notice => "Item updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @item = Item.find(params[:id])

    @item.destroy

    redirect_to "/items", :notice => "Item deleted."
  end

  def errand_route
    # convert user street address to coordinates
    @street_address = params[:user_street_address]

    url_safe_street_address = URI.encode(@street_address)

    url = "http://maps.googleapis.com/maps/api/geocode/json?address="+url_safe_street_address

    parsed_data = JSON.parse(open(url).read)

    @lat = parsed_data["results"][0]["geometry"]["location"]["lat"]

    @lng = parsed_data["results"][0]["geometry"]["location"]["lng"]


    # Lookup item + location in Goodzer data base and return nearest store

    render("errand_route.html.erb")
  end
end

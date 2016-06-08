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
      redirect_to "/", :notice => "Item created successfully."
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
      redirect_to "/", :notice => "Item updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @item = Item.find(params[:id])

    @item.destroy

    redirect_to "/", :notice => "Item deleted."
  end

  def errand_route
    # define items to be found
    @items = Item.all

    # convert user street address to coordinates
    @street_address = params[:user_street_address]

    url_safe_street_address = URI.encode(@street_address)

    geocode_url = "http://maps.googleapis.com/maps/api/geocode/json?address="+url_safe_street_address

    geocode_parsed_data = JSON.parse(open(geocode_url).read)

    @lat = geocode_parsed_data["results"][0]["geometry"]["location"]["lat"]

    @lng = geocode_parsed_data["results"][0]["geometry"]["location"]["lng"]

    # Find closest store for each item with Goodzer API using item names (search queries), lat, lng, sorting, api key
    # Sample Goodzer API request: https://api.goodzer.com/products/v0.1/search_stores/?query=v-neck+sweater&lat=40.714353&lng=-74.005973&radius=5&priceRange=30:120&apiKey=<Your_API_key>

    goodzer_api_key = "01c8f693b69ab9cd96a63aebd789fdf8"

    url_safe_search_query = Item.find(3).name.gsub(' ', '+').to_s

    @goodzer_url = " https://api.goodzer.com/products/v0.1/search_stores/?query="+url_safe_search_query+"&lat="+@lat.to_s+"&lng="+@lng.to_s+"&sorting=distance&apiKey="+goodzer_api_key

    #goodzer_parsed_data = JSON.parse(open(@goodzer_url).read)

    #@closeststore = goodzer_parsed_data["stores"][0]["name"]
    #@closest_store_lat = goodzer_parsed_data["stores"][0]["locations"][0]["lat"]
    #@closest_store_lng = goodzer_parsed_data["stores"][0]["locations"][0]["lng"]

    # Find optimized directions for locations using Google Maps API
    #Format for Maps API request: https://maps.googleapis.com/maps/api/directions/json?parameters
    #origin=@lat.to_s+","+@lng.to_s

    #geocode_url = "http://maps.googleapis.com/maps/api/geocode/json?address="+url_safe_street_address

    #geocode_parsed_data = JSON.parse(open(geocode_url).read)


    render("errand_route.html.erb")
  end
end

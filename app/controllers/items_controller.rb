require 'open-uri'

class ItemsController < ApplicationController
  def index
    @items = current_user.items
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
    @items = current_user.items

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

    @closest_stores = []
    @closest_stores_addresses = []
    @closest_store_lats = []
    @closest_store_lngs = []
    @waypoints = []

    @items.each do |item|
      url_safe_search_query = item.name.gsub(' ', '+').to_s

      @goodzer_url = "https://api.goodzer.com/products/v0.1/search_stores/?query="+url_safe_search_query+"&lat="+@lat.to_s+"&lng="+@lng.to_s+"&sorting=distance&apiKey="+goodzer_api_key

      goodzer_parsed_data = JSON.parse(open(@goodzer_url).read)

      @closest_store = goodzer_parsed_data["stores"][0]["name"].to_s
      @closest_store_address = goodzer_parsed_data["stores"][0]["locations"][0]["address"].to_s
      @closest_store_lat = goodzer_parsed_data["stores"][0]["locations"][0]["lat"].to_s
      @closest_store_lng = goodzer_parsed_data["stores"][0]["locations"][0]["lng"].to_s
      @closest_stores.push(@closest_store)
      @closest_stores_addresses.push(@closest_store_address)
      @closest_store_lats.push(@closest_store_lng)
      @closest_store_lngs.push(@closest_store_lng)

      @waypoints.push(@closest_store_lat+","+@closest_store_lng)
    end

    #Find optimized directions for locations using Google Maps API
    #Format for Maps API request: https://maps.googleapis.com/maps/api/directions/json?parameters

    google_maps_api_key = "AIzaSyCq7AYXb_d-xjevXvn_0ub-w3P6B2sZMRU"
    origin = @lat.to_s+","+@lng.to_s

    @directions_url_waypoints = @waypoints.join('|')

    @directions_url ="https://maps.googleapis.com/maps/api/directions/json?origin="+origin+"&destination="+origin+"&waypoints=optimize:true|"+@directions_url_waypoints+"&key="+google_maps_api_key

    geocode_parsed_data = JSON.parse(open(@directions_url).read)

    @optimized_waypoint_legs = geocode_parsed_data["routes"][0]["legs"]

    @optimized_waypoint_destination_coordinates = []
    @optimized_waypoint_destination_addresses = []
    @optimized_waypoint_legs.each do |leg|
      lat = leg["end_location"]["lat"].to_s
      lng = leg["end_location"]["lng"].to_s
      @optimized_waypoint_destination_coordinates.push(lat+","+lng)
      address = leg["end_address"]
      @optimized_waypoint_destination_addresses.push(address)
    end

    @optimized_waypoints_for_embedded_map = @optimized_waypoint_destination_coordinates.join('|')

    #Embed map with directions
    @embeded_map_link ="https://www.google.com/maps/embed/v1/directions?key=AIzaSyCq7AYXb_d-xjevXvn_0ub-w3P6B2sZMRU&origin="+origin+"&destination="+origin+"&waypoints="+@optimized_waypoints_for_embedded_map

    #provide link to google maps directions
    #@optimized_waypoints_for_link_to_google_maps = @optimized_waypoint_destination_coordinates.join('/')
    #  @link_to_google_maps ="https://www.google.com/maps/dir/"+origin+"/"+@optimized_waypoints_for_link_to_google_maps+"/"+origin


    render("errand_route.html.erb")
  end
end

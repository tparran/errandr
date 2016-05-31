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
end

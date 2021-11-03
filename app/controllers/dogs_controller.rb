class DogsController < ApplicationController
  require "will_paginate/array"
  
  before_action :set_dog, only: [:show, :edit, :update, :destroy]
  before_action :verify_owner, only: [:edit, :update, :destroy]

  # GET /dogs
  # GET /dogs.json
  def index
    start = Time.now
    if params[:sort] && params[:sort] == "likes_last_hour"
      query = 
        "SELECT * FROM dogs
        LEFT JOIN (
        SELECT likes.dog_id, COUNT(*) AS count FROM likes
        WHERE likes.created_at > date('now', '-1 hour')
        GROUP BY likes.dog_id
        )
        AS likes_last_hour ON dogs.id = likes_last_hour.dog_id
        ORDER BY likes_last_hour.count DESC"
        
      @dogs = Dog.find_by_sql(query)
      # @dogs = Dog.all.sort_by { |dog| dog.likes.where(created_at: 1.hour.ago..Time.now).count }
      # .reverse
    else
      @dogs = Dog.all
    end
    @dogs = @dogs.paginate(page: params[:page], per_page: 5)
    finish = Time.now
    print "Hey! It took #{finish - start} seconds to run this query"

    # With SQL on 10 dogs, operation takes 0.005423 seconds
    # With sort_by on 10 dogs, operation takes 0.004679 seconds
    # With SQL on 10,000 dogs, operation takes 0.003428 seconds
    # With sort_by on 10,000 dogs, operation takes 0.006565 seconds
    # SQL is 86% as fast when the table is small and 190% as fast when the table is large
  end

  # GET /dogs/1
  # GET /dogs/1.json
  def show
    @likeable = current_user && Like.where(user_id: current_user.id, dog_id: @dog.id).blank?
  end

  # GET /dogs/new
  def new
    @dog = Dog.new
  end

  # GET /dogs/1/edit
  def edit
  end

  # POST /dogs
  # POST /dogs.json
  def create
    @dog = Dog.new(dog_params)

    respond_to do |format|
      if @dog.save
        @dog.images.attach(params[:dog][:image]) if params[:dog][:image].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully created.' }
        format.json { render :show, status: :created, location: @dog }
      else
        format.html { render :new }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dogs/1
  # PATCH/PUT /dogs/1.json
  def update
    respond_to do |format|
      if @dog.update(dog_params)
        @dog.images.attach(params[:dog][:image]) if params[:dog][:image].present?

        format.html { redirect_to @dog, notice: 'Dog was successfully updated.' }
        format.json { render :show, status: :ok, location: @dog }
      else
        format.html { render :edit }
        format.json { render json: @dog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dogs/1
  # DELETE /dogs/1.json
  def destroy
    @dog.destroy
    respond_to do |format|
      format.html { redirect_to dogs_url, notice: 'Dog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dog
    @dog = Dog.find(params[:id])
  end

  def verify_owner
    unless current_user == @dog.owner
      redirect_to @dog, notice: "You are not this pup's owner. Please do not try to change or delete pups that are not yours."
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dog_params
    params.require(:dog).permit(:name, :description, :user_id, :images => [])
  end
end

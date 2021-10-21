class LikesController < ApplicationController

  before_action :verify_not_owner, only: [:create]

  def create
    @like = Like.new(like_params)

    unless @like.save
      render json: @like.errors, status: :unprocessable_entity
    end
  end

  private

  def verify_not_owner
    @dog = Dog.find(params[:like][:dog_id])
    if current_user.id == @dog.user_id
      redirect_to dogs_path
    end
  end

  def like_params
    params.require(:like).permit(:id, :user_id, :dog_id)
  end
end

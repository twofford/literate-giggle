require 'rails_helper'

RSpec.describe LikesController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe '#create' do

  before do
    user = create(:user)
    allow(controller).to receive(:current_user).and_return(user)
  end

  let(:user) { FactoryBot.create(:user) }
  let(:dog) { FactoryBot.create(:dog) }

    it "creates a single like" do
      post :create, params: { like: { user_id: user.id, dog_id: dog.id } }
      expect(Like.count).to eq(1)
    end
  end
  
end

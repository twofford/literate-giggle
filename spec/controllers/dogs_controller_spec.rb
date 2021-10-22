require 'rails_helper'

RSpec.describe DogsController, type: :controller do
  include Devise::Test::ControllerHelpers
  
  describe '#index' do
    let(:owner) { FactoryBot.create(:user) }
    it 'displays up to 5 dogs' do
      6.times { create(:dog, user_id: owner.id) }
      get :index
      expect(assigns(:dogs).size).to eq(5)
    end
  end

  describe '#show' do
    before do
      user = create(:user)
      allow(controller).to receive(:current_user).and_return(user)
      dog = create(:dog)
      2.times { create(:like, dog_id: dog.id ) }
      instance_variable_set(:@dog, dog)
    end

    it "sets whether the current user can like the dog to an instance variable" do
      get :show, params: { id: @dog.id }
      expect(assigns(:likeable)).to be_in([true, false])
    end

    it "sets the dog's likes to an instance variable" do
      get :show, params: { id: @dog.id }
      expect(assigns(:likes).size).to eq(2)
      expect(assigns(:likes)).to be_an(ActiveRecord::Relation)
    end
  end
end

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
end

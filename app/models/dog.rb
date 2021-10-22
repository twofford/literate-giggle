class Dog < ApplicationRecord
  belongs_to :owner, class_name: :User, foreign_key: :user_id
  has_many :likes
  has_many_attached :images
end

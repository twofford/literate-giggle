FactoryBot.define do
  factory :like do
    association :user, factory: :user
    association :dog, factory: :dog
  end
end
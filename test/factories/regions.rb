FactoryBot.define do
  factory :region do
    sequence(:name) { |n| "Region #{n}" }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
  end
end

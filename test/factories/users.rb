FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password { "password" }
  end

  trait :admin do
    after(:create) do |user|
      create(:admin_role, user: user)
    end
  end

  trait :reporter do
    after(:create) do |user|
      create(:reporter_role, user: user)
    end
  end

  trait :analyst do
    after(:create) do |user|
      create(:analyst_role, user: user)
    end
  end
end

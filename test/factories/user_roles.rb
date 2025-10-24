FactoryBot.define do
  factory :admin_role, class: "UserRole" do
    role { "admin" }
    association :user
  end

  factory :reporter_role, class: "UserRole" do
    role { "reporter" }
    association :user
  end

  factory :analyst_role, class: "UserRole" do
    role { "analyst" }
    association :user
  end
end

FactoryBot.define do
  factory :admin_role, class: "UserRole" do
    role { "admin" }
    user
  end

  factory :reporter_role, class: "UserRole" do
    role { "reporter" }
    user
  end

  factory :analyst_role, class: "UserRole" do
    role { "analyst" }
    user
  end
end

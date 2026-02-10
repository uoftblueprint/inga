FactoryBot.define do
  factory :report do
    start_date { Time.zone.yesterday }
    end_date { Time.zone.today }
  end
end

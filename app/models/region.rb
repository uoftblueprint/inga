class Region < ApplicationRecord
  has_many :subprojects

  validates :name, presence: true, uniqueness: true
  validates :latitude,
            numericality: {
              greater_than_or_equal_to: -90,
              less_than_or_equal_to: 90
            }
  validates :longitude,
            numericality: {
              greater_than_or_equal_to: -180,
              less_than_or_equal_to: 180
            }
end

class Region < ApplicationRecord
  has_many :subprojects

  validates :name, presence: true, uniqueness: true
end

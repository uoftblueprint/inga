class Project < ApplicationRecord
  has_many :subprojects
  has_many :reports

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end

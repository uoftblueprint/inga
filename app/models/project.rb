class Project < ApplicationRecord
  validates :name, presence: true

  has_many :subprojects
  has_many :reports

  scope :active, -> { where(active: true) }
end

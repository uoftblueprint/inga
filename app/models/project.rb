class Project < ApplicationRecord
  has_many :subprojects
  has_many :reports

  scope :active, -> { where(active: true) }
end

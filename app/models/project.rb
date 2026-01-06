class Project < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :subprojects, dependent: :destroy
  has_many :reports

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
end

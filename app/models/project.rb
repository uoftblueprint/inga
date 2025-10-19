class Project < ApplicationRecord
  has_many :subprojects
  has_many :reports
end

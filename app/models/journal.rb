class Journal < ApplicationRecord
  belongs_to :subproject
  belongs_to :user

  has_many_attached :images
end

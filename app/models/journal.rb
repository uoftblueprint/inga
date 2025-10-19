class Journal < ApplicationRecord
  belongs_to :subproject
  belongs_to :user
end

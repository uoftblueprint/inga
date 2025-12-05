class UserRole < ApplicationRecord
  belongs_to :user
  enum :role, { admin: "admin", reporter: "reporter", analyst: "analyst" }
  
  validates :role, uniqueness: { scope: :user_id }
end

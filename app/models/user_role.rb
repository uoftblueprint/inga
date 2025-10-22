class UserRole < ApplicationRecord
  belongs_to :user
  enum :role, { admin: "admin", reporter: "reporter", analyst: "analyst" }
end

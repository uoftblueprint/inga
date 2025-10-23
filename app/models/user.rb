class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  has_many :user_roles
  has_many :journals
  has_many :log_entries

  def has_roles?(*roles)
    user_roles.any? { |user_role| roles.include?(user_role.role.to_sym) }
  end
end

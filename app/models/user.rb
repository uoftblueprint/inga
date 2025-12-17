class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  has_many :user_roles, dependent: :destroy
  has_many :journals
  has_many :log_entries

  def roles=(roles)
    roles ||= []
    transaction do
      user_roles.where.not(role: roles).destroy_all
      roles.each do |role|
        user_roles.find_or_create_by!(role:)
      end
    end
  end

  def has_roles?(*roles)
    user_roles.any? { |user_role| roles.include?(user_role.role.to_sym) }
  end
end

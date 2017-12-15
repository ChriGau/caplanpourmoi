class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :constraints, dependent: :destroy
  has_many :plannings, through: :teams
  has_many :slots, dependent: :destroy
  has_many :roles, through: :role_users
  has_many :role_users
  has_many :teams, dependent: :destroy
  has_attachment :profile_picture

  def concatenate_first_and_last_name
    first_name + " " + last_name
  end

  def is_skilled?(role_id)
    roles.map(&:id).include?(role_id)
  end

  def is_available?(start_at, end_at)
    constraints.where('start_at <= ? and end_at >= ?', end_at, start_at).empty?
  end

  def is_skilled_and_available?(start_at, end_at, role_id)
    is_skilled?(role_id) && is_available?(start_at, end_at)
  end

end

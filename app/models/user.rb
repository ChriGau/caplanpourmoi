class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :constraints, dependent: :destroy
  has_many :plannings, through: :teams
  has_many :slots, dependent: :destroy
  has_many :roles, through: :role_users
  has_many :teams, dependent: :destroy
  has_attachment :profile_picture
end

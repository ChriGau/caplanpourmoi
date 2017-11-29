class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_many :constraints
  has_many :plannings, through: :teams
  has_many :slots
  has_many :roles, through: :role_users
  has_many :teams
  has_many :role_users
  has_attachment :profile_picture

  def role_id
    # get array of role_id concerning a user
    array_of_role_id = []
    roleusers = RoleUser.where(user_id: self.id)
    roleusers.each do |roleuser|
      array_of_role_id << roleuser.role_id
    end
    return array_of_role_id
  end

  def constraint
    # returns list of constraints related to this user
    Constraint.where(user_id: self.id)
  end


end

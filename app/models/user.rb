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

  def constraint
    # returns list of constraints related to this user
    Constraint.where(user_id: self.id)
  end

  def concatenate_first_and_last_name
    first_name + " " + last_name
  end

  def is_skilled?(role_id)
    self.get_array_of_user_role_id.include?(role_id)
  end

  def is_available?(start_at, end_at)
    available = true
      self.constraint.each do |constraint|
        unless available == false
          if not((start_at <= constraint.end_at) or (end_at >= constraint.start_at))
            available = false
          end
        end
      end
      return available
  end

  def is_skilled_and_available?(start_at, end_at, role_id)
    if is_skilled?(role_id) == true and is_available?(start_at, end_at) == true
      return true
    else
      return false
    end
  end

  def get_array_of_user_role_id
    array = []
    self.roles.each do |role|
      array << role.id
    end
    return array
  end

end

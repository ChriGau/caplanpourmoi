# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  working_hours          :integer
#  is_owner               :boolean
#  first_name             :string
#  last_name              :string
#

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

# == Schema Information
#
# Table name: roles
#
#  id           :integer          not null, primary key
#  name         :string
#  role_color   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  slotgroup_id :integer
#
# Indexes
#
#  index_roles_on_slotgroup_id  (slotgroup_id)
#

class Role < ApplicationRecord
  has_many :users, through: :role_users
  has_many :solution_slots, through: :slots
  has_many :role_users


  # rubocop:disable MethodLength
  def self.color_list
    {
      slotcolor1: {
        name_fr: 'Bleu ciel couvert',
        name_en: 'Dark sky blue',
        code: '#87BCDE'
      },
      slotcolor2: {
        name_fr: 'Rose framboise',
        name_en: 'Pink rasberry',
        code: '#89043D'
      },
      slotcolor3: {
        name_fr: 'Or las-vegas',
        name_en: 'Vegas gold',
        code: '#C6B849'
      },
      slotcolor4: {
        name_fr: 'Mauve lavande',
        name_en: 'English lavender',
        code: '#8D816F'
      },
      slotcolor5: {
        name_fr: 'Brun castor',
        name_en: 'Beaver',
        code: '#AD7A99'
      },
      slotcolor6: {
        name_fr: 'Gris indépendance',
        name_en: 'Independance',
        code: '#3E5665'
      },
      slotcolor7: {
        name_fr: 'Bleu nuit',
        name_en: 'Midnight blue',
        code: '#1D1D75'
      },
      slotcolor8: {
        name_fr: 'Jaune maïs',
        name_en: 'Maize',
        code: '#FFED6E'
      },
      slotcolor9: {
        name_fr: 'Violet Aubergine',
        name_en: 'Eggplant',
        code: '#5F4354'
      },
      slotcolor10: {
        name_fr: 'Jaune ambre',
        name_en: 'Ambre',
        code: '#CF9700'
      }
    }
  end
  # rubocop:enable MethodLength
end

# == Schema Information
#
# Table name: colors
#
#  id               :integer          not null, primary key
#  name_fr          :text
#  name_eng         :text
#  hexadecimal_code :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Color < ApplicationRecord

  has_many :roles

end

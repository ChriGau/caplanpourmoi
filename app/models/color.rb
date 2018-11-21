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

  def brightness
    rgb = hexadecimal_code.gsub("#", "").scan(/../).map {|color| color.hex}
    Math.sqrt(
      0.299 * rgb[0]**2 +
      0.587 * rgb[1]**2 +
      0.114 * rgb[2]**2
    )
  end

  def dark?
    brightness < 150
  end
end

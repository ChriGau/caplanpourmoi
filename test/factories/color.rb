require 'faker'

FactoryBot.define do
  factory :color do
    name_eng {Faker::Color.color_name}
    name_fr {Faker::Food.dish} #=> "Caesar Salad"
    hexadecimal_code { Faker::Color.hex_color}
  end
end

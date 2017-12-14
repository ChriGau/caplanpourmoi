require 'faker'

FactoryBot.define do
  factory :role do
    name {Faker::Job.title}
    role_color { Faker::Color.hex_color}
  end
end

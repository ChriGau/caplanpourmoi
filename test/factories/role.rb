require 'faker'

FactoryBot.define do
  factory :role do
    name {Faker::Job.title}
    color_id Color.first.id
  end
end

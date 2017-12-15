require 'faker'

def add_role(user)
  role = create(:role)
  user.roles << role

end

def add_roles(user)
  rand(1..3).times { user.roles << create(:role) }
end


FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password 'password'
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    working_hours {rand(17..40)}

  end

  factory :user_with_role, parent: :user do
    after(:create) { |user| add_role(user) }
  end

  factory :user_with_roles, parent: :user do
    after(:create) { |user| add_roles(user) }
  end

end

require 'faker'

puts "---------------------------------"
puts "         SEEDING        "
puts "---------------------------------"

puts "1 - Cleaning database"
puts ""

# destroy RoleUser before Role
# destroy Slot before planning
RoleUser.destroy_all
Constraint.destroy_all
ComputeSolution.destroy_all
SolutionSlot.destroy_all
Slot.destroy_all
Role.destroy_all
Team.destroy_all
Solution.destroy_all
Planning.destroy_all
User.destroy_all

puts "2 - Creating owner"
puts ""

def open_image(path)
  File.open(Rails.root.join("db", path), "r")
end

User.create!(email: "boss@boutique.com",
            working_hours: 50,
            is_owner: true,
            first_name: "jean",
            last_name: "patron",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_1m.jpg")
  )

puts "3 - Creating Planning"
puts ""



p = Planning.new
p.week_number = 37
p.year = 2017
p.save!

p = Planning.new
p.week_number = 35
p.year = 2017
p.save!

p = Planning.new
p.week_number = 36
p.year = 2017
p.save!

i = 1
10.times do
  p = Planning.new
  p.week_number = 37 + i
  p.year = 2017
  p.save!
  i += 1
end

p = Planning.first


puts "4 - Creating roles"
puts ""

Role.create!(name: "vendeur",
            role_color: Role.color_list[:slotcolor1][:code]
            )
Role.create!(name: "mécano",
            role_color: Role.color_list[:slotcolor2][:code]
            )
Role.create!(name: "barista",
            role_color: Role.color_list[:slotcolor3][:code]
            )
Role.create!(name: "patron",
            role_color: "black"
            )
Role.create!(name: "chef",
            role_color: "blue"
            )
Role.create!(name: "commis",
            role_color: "pink"
            )

# un-assigned value : color_role


puts "5 - Creating users (aka team members)"
puts ""

User.create!(email: "pierre@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "pierre",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_2m.jpg")
  )
User.create!(email: "paul@boutique.com",
            working_hours: 37,
            is_owner: false,
            first_name: "paul",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_3m.jpg")
  )
User.create!(email: "jacques@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "jacques",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_7m.jpg")
  )
User.create!(email: "jeannie@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "jeannie",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_4f.jpg")
  )
User.create!(email: "nelson@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "nelson",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_10m.jpeg")
  )
User.create!(email: "bob@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "bob",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_11m.jpg")
  )
User.create!(email: "michel@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "michel",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_13m.jpg")
  )
User.create!(email: "axel@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "axel",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_15m.jpg")
  )
User.create!(email: "valentine@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "valentine",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_5f.jpg")
  )
User.create!(email: "emma@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "emma",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_6f.jpg")
  )
User.create!(email: "hortense@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "hortense",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_8f.jpg")
  )
User.create!(email: "joseth@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "joseth",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_9f.jpg")
  )
User.create!(email: "magalie@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "magalie",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_12f.jpeg")
  )
User.create!(email: "arielle@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "arielle",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_14f.jpg")
  )

# cree user "no solution" pour le cas où pas de solution pour le slot
User.create!(email: "wtf@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "no solution",
            last_name: "Last name",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_no.jpg")
  )

# Creation des users pour test cas Ecomotiv
# User.create!(email: "benedict@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "benedict",
#             last_name: "cumberbach",
#             password: "password",
#             profile_picture: open_image("./images_seeds/benedict_cumberbach.png")
#   )

# User.create!(email: "roxane@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "roxanne",
#             last_name: "machin",
#             password: "password",
#             profile_picture: open_image("./images_seeds/roxanne.png")
#   )

# User.create!(email: "caroline@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "caroline",
#             last_name: "la tortue",
#             password: "password",
#             profile_picture: open_image("./images_seeds/caroline.png")
#   )

# User.create!(email: "ninon@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "ninon",
#             last_name: "the rockstar",
#             password: "password",
#             profile_picture: open_image("./images_seeds/ninon.png")
#   )

# User.create!(email: "oahn@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "oanh",
#             last_name: "da boss",
#             password: "password",
#             profile_picture: open_image("./images_seeds/oanh.png")
#   )

# User.create!(email: "virginie@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "virginie",
#             last_name: "td",
#             password: "password",
#             profile_picture: open_image("./images_seeds/virginie.png")
#   )

# User.create!(email: "lorraine@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "lorraine",
#             last_name: "cauquil",
#             password: "password",
#             profile_picture: open_image("./images_seeds/lorraine.png")
#   )

# User.create!(email: "mariana@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "mariana",
#             last_name: "Columbia",
#             password: "password",
#             profile_picture: open_image("./images_seeds/mariana.png")
#   )

# User.create!(email: "david@boutique.com",
#             working_hours: 32,
#             is_owner: false,
#             first_name: "david",
#             last_name: "abitboul",
#             password: "password",
#             profile_picture: open_image("./images_seeds/david.png")
#   )


puts "6 - assigning roles to members"
puts ""

a = User.find_by_first_name('pierre')
b = RoleUser.new
b.role_id = Role.find_by_name("mécano").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('jacques')
b = RoleUser.new
b.role_id = Role.find_by_name("mécano").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('jeannie')
b = RoleUser.new
b.role_id = Role.find_by_name("mécano").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('nelson')
b = RoleUser.new
b.role_id = Role.find_by_name("vendeur").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('bob')
b = RoleUser.new
b.role_id = Role.find_by_name("mécano").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('axel')
b = RoleUser.new
b.role_id = Role.find_by_name("vendeur").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('valentine')
b = RoleUser.new
b.role_id = Role.find_by_name("vendeur").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('emma')
b = RoleUser.new
b.role_id = Role.find_by_name("vendeur").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('hortense')
b = RoleUser.new
b.role_id = Role.find_by_name("mécano").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('joseth')
b = RoleUser.new
b.role_id = Role.find_by_name("vendeur").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('arielle')
b = RoleUser.new
b.role_id = Role.find_by_name("vendeur").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('paul')
b = RoleUser.new
b.role_id = Role.find_by_name("barista").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('michel')
b = RoleUser.new
b.role_id = Role.find_by_name("barista").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('magalie')
b = RoleUser.new
b.role_id = Role.find_by_name("barista").id
b.user_id = a.id
b.save!

a = User.find_by_first_name('jean')
b = RoleUser.new
b.role_id = Role.find_by_name("patron").id
b.user_id = a.id
b.save!

# Roles pour l'Ecomotiv
# a = User.find_by_first_name('benedict')
# b = RoleUser.new
# b.role_id = Role.find_by_name("barista").id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('roxanne')
# b = RoleUser.new
# b.role_id = Role.find_by_name("chef").id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('caroline')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('ninon')
# b = RoleUser.new
# b.role_id = Role.find_by_name('chef').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('ninon')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('oanh')
# b = RoleUser.new
# b.role_id = Role.find_by_name('chef').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('oanh')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('virginie')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('lorraine')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('lorraine')
# b = RoleUser.new
# b.role_id = Role.find_by_name('commis').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('mariana')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('david')
# b = RoleUser.new
# b.role_id = Role.find_by_name('barista').id
# b.user_id = a.id
# b.save!

# a = User.find_by_first_name('david')
# b = RoleUser.new
# b.role_id = Role.find_by_name('commis').id
# b.user_id = a.id
# b.save!

puts "7 - assigning constraints to members"
puts ""

# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-06 08:00",
                  end_at: "2017-09-06 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-11 16:00",
                  end_at: "2017-09-11 22:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-12 16:00",
                  end_at: "2017-09-12 22:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-13 16:00",
                  end_at: "2017-09-13 22:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-14 16:00",
                  end_at: "2017-09-14 22:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-15 16:00",
                  end_at: "2017-09-15 22:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-27 08:00",
                  end_at: "2017-09-27 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-04 08:00",
                  end_at: "2017-10-04 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-11 08:00",
                  end_at: "2017-10-11 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-18 08:00",
                  end_at: "2017-10-18 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-24 08:00",
                  end_at: "2017-10-24 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )


# pierre lundi matin
Constraint.create!(start_at: "2017-09-11 16:00",
                  end_at: "2017-09-11 22:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# pierre jeudi matin
Constraint.create!(start_at: "2017-09-14 08:00",
                  end_at: "2017-09-14 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )

# pierre vendredi matin
Constraint.create!(start_at: "2017-09-15 08:00",
                  end_at: "2017-09-15 12:00",
                  user_id: User.find_by_first_name('pierre').id
                  )
# emma lundi matin
Constraint.create!(start_at: "2017-09-12 08:00",
                  end_at: "2017-09-12 12:00",
                  user_id: User.find_by_first_name('emma').id
                  )
# emma jeudi matin
Constraint.create!(start_at: "2017-09-13 08:00",
                  end_at: "2017-09-13 12:00",
                  user_id: User.find_by_first_name('emma').id
                  )
# bob lundi matin
Constraint.create!(start_at: "2017-09-11 08:00",
                  end_at: "2017-09-11 12:00",
                  user_id: User.find_by_first_name('bob').id
                  )
# bob jeudi matin
Constraint.create!(start_at: "2017-09-14 08:00",
                  end_at: "2017-09-14 12:00",
                  user_id: User.find_by_first_name('bob').id
                  )

# bobvendredi matin
Constraint.create!(start_at: "2017-09-15 08:00",
                  end_at: "2017-09-15 12:00",
                  user_id: User.find_by_first_name('bob').id
                  )
Constraint.create!(start_at: "2017-09-03 08:00",
                  end_at: "2017-09-03 12:00",
                  user_id: User.find_by_first_name('bob').id
                  )
Constraint.create!(start_at: "2017-09-05 08:00",
                  end_at: "2017-09-05 12:00",
                  user_id: User.find_by_first_name('bob').id
                  )
Constraint.create!(start_at: "2017-09-01 08:00",
                  end_at: "2017-09-01 12:00",
                  user_id: User.find_by_first_name('bob').id
                  )



puts "8 - assigning teams to members"
puts ""
# tous les users de l base
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("pierre").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("paul").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("jacques").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("jeannie").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("bob").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("axel").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("valentine").id
  )
Team.create!(planning_id: p.id,
            user_id: User.find_by_first_name("emma").id
  )

puts "9 - adding SLOTS to planning + solution"
puts ""

p = Planning.first
p35 = Planning.find_by_week_number(35)
p36 = Planning.find_by_week_number(36)
p38 = Planning.find_by_week_number(38)
p39 = Planning.find_by_week_number(39)
p40 = Planning.find_by_week_number(40)




##11/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 08:00",
  end_at: "2017-09-11 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("pierre").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 08:00",
  end_at: "2017-09-11 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jeannie").id
  )

# 2
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jacques").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("bob").id
  )
# 3
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 10:00",
  end_at: "2017-09-11 14:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 10:00",
  end_at: "2017-09-11 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("valentine").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 10:00",
  end_at: "2017-09-11 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )

#4
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 15:00",
  end_at: "2017-09-11 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("valentine").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )

#5
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 08:00",
  end_at: "2017-09-11 15:30",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("paul").id
  )

##############12/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 08:00",
  end_at: "2017-09-12 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("pierre").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 08:00",
  end_at: "2017-09-12 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jeannie").id
  )

#7
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 14:00",
  end_at: "2017-09-12 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jacques").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 14:00",
  end_at: "2017-09-12 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("bob").id
  )

#8
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 10:00",
  end_at: "2017-09-12 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 10:00",
  end_at: "2017-09-12 14:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("valentine").id
  )
#9
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 14:00",
  end_at: "2017-09-12 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 15:00",
  end_at: "2017-09-12 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("valentine").id
  )

#10
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 8:00",
  end_at: "2017-09-12 15:30",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("paul").id
  )
#### 13/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 08:00",
  end_at: "2017-09-13 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("pierre").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 08:00",
  end_at: "2017-09-13 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jeannie").id
  )

#12
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 14:00",
  end_at: "2017-09-13 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jacques").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 14:00",
  end_at: "2017-09-13 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("bob").id
  )


# TO BE CRETED DURING DEMO
# Slot.create!(
#   planning_id: p.id,
#   start_at: "2017-09-13 10:00",
#   end_at: "2017-09-13 18:00",
#   role_id: Role.find_by_name("vendeur").id,
#   user_id: User.find_by_first_name("valentine").id
#   )

# #15
# Slot.create!(
#   planning_id: p.id,
#   start_at: "2017-09-13 10:00",
#   end_at: "2017-09-13 15:30",
#   role_id: Role.find_by_name("barista").id,
#   user_id: User.find_by_first_name("paul").id
#   )

#######14/09

#16
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 08:00",
  end_at: "2017-09-14 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("pierre").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 08:00",
  end_at: "2017-09-14 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jeannie").id
  )

#
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 14:00",
  end_at: "2017-09-14 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jacques").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 14:00",
  end_at: "2017-09-14 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("bob").id
  )

#18
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 10:00",
  end_at: "2017-09-14 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )

#19
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 10:00",
  end_at: "2017-09-14 14:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 14:00",
  end_at: "2017-09-14 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 15:00",
  end_at: "2017-09-14 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )
#20
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 08:00",
  end_at: "2017-09-14 15:30",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("paul").id
  )

#### 15/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 08:00",
  end_at: "2017-09-15 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("pierre").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 08:00",
  end_at: "2017-09-15 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jeannie").id
  )
#22
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 14:00",
  end_at: "2017-09-15 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jacques").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 14:00",
  end_at: "2017-09-15 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("bob").id
  )
#23
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 10:00",
  end_at: "2017-09-15 14:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 10:00",
  end_at: "2017-09-15 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )
#24
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 15:00",
  end_at: "2017-09-15 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 14:00",
  end_at: "2017-09-15 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 8:00",
  end_at: "2017-09-15 15:30",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("paul").id
  )

#### 16/09 Samedi Grosse journée

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 08:00",
  end_at: "2017-09-16 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("pierre").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 08:00",
  end_at: "2017-09-16 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jeannie").id
  )
#27
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("jacques").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 20:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("bob").id
  )
#28
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 10:00",
  end_at: "2017-09-16 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 10:00",
  end_at: "2017-09-16 13:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("valentine").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 10:00",
  end_at: "2017-09-16 14:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )
#29
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("axel").id
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("valentine").id
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 15:00",
  end_at: "2017-09-16 18:00",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("emma").id
  )


### Barista a trop travaillé

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 8:00",
  end_at: "2017-09-16 15:30",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: p35.id,
  start_at: "2017-08-28 07:00",
  end_at: "2017-08-28 15:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("magalie").id
  )

Slot.create!(
  planning_id: p36.id,
  start_at: "2017-09-4 07:00",
  end_at: "2017-09-4 15:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("magalie").id
  )

Slot.create!(
  planning_id: p38.id,
  start_at: "2017-09-18 07:00",
  end_at: "2017-09-18 15:00",
  role_id: Role.find_by_name("mécano").id,
  )

Slot.create!(
  planning_id: p39.id,
  start_at: "2017-09-25 07:00",
  end_at: "2017-09-25 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

puts "10 - Fake status planning 37 for demo"
puts ""

Planning.first.not_started!

puts "11 - 2 new slots on planning n°18 to test slotgroups"

Slot.create!(
  planning_id: Planning.find_by(week_number: 35).id,
  start_at: "2017-08-29 07:00",
  end_at: "2017-08-29 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 35).id,
  start_at: "2017-08-29 07:00",
  end_at: "2017-08-29 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

# Creation de slots pour la semaine 39
# baristas
Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-25 07:00",
  end_at: "2017-09-25 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-26 07:00",
  end_at: "2017-09-26 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-27 07:00",
  end_at: "2017-09-27 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-28 07:00",
  end_at: "2017-09-28 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-29 07:00",
  end_at: "2017-09-29 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-30 07:00",
  end_at: "2017-09-30 15:00",
  role_id: Role.find_by_name("barista").id,
  user_id: User.find_by_first_name("no solution").id
  )
# mécanos
Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-25 07:30",
  end_at: "2017-09-25 15:30",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-26 07:30",
  end_at: "2017-09-26 16:15",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-27 07:30",
  end_at: "2017-09-27 14:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )
Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-27 07:30",
  end_at: "2017-09-27 16:15",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-28 07:30",
  end_at: "2017-09-28 15:00",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-29 07:30",
  end_at: "2017-09-29 16:15",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-29 07:30",
  end_at: "2017-09-29 16:15",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-30 07:30",
  end_at: "2017-09-30 16:15",
  role_id: Role.find_by_name("mécano").id,
  user_id: User.find_by_first_name("no solution").id
  )

# vendeurs
Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-25 09:00",
  end_at: "2017-09-25 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-26 09:00",
  end_at: "2017-09-26 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-27 09:00",
  end_at: "2017-09-27 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-28 09:00",
  end_at: "2017-09-28 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-29 14:20",
  end_at: "2017-09-29 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-30 14:20",
  end_at: "2017-09-30 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-25 14:20",
  end_at: "2017-09-25 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-26 14:20",
  end_at: "2017-09-26 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-27 14:20",
  end_at: "2017-09-27 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-28 14:20",
  end_at: "2017-09-28 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-29 14:20",
  end_at: "2017-09-29 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 39).id,
  start_at: "2017-09-30 14:20",
  end_at: "2017-09-30 19:30",
  role_id: Role.find_by_name("vendeur").id,
  user_id: User.find_by_first_name("no solution").id
  )

puts ""
puts  "  >> #{User.count} users created"
puts  "  >> #{Role.count} roles created"
puts  "  >> #{Team.count} orders created"
puts  "  >> #{Slot.count} slots created"
puts  "  >> #{Planning.count} planning created (for week 37)"
puts  "  >> #{Constraint.count} constraints created"
puts ""
puts "---------------------------------"
puts "       SEEDING COMPLETED         "
puts "---------------------------------"



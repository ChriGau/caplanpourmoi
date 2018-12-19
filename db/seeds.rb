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
CalculSolutionV1.destroy_all
ComputeSolution.destroy_all
SolutionSlot.destroy_all
Slot.destroy_all
Role.destroy_all
Color.destroy_all
Team.destroy_all
Solution.destroy_all
Planning.destroy_all
User.destroy_all
AlgoStat.destroy_all

puts "2 - Creating owner"
puts ""

def open_image(path)
  File.open(Rails.root.join("db", path), "r")
end
time_with_zone = Time.zone.now
User.create!(email: "boss@boutique.com",
            working_hours: 50,
            is_owner: true,
            first_name: "jean",
            last_name: "patron",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_1m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )

puts "3 - Creating Planning"
puts ""

colors = [
          ["Rose framboise", "Pink Rasberry", "#89043D"],
          ["Bleu ciel couvert", "sky blue", "#87BCDE"],
          ["Or las-vegas", "Vegas gold", "#C6B849"],
          ["Mauve lavande", "English lavender", "#AD7A99"],
          ["Gris indépendance", "Independance", "#3E5665"],
          ["Brun castor", "Beaver", "#8D816F"],
          ["Bleu nuit", "Midnight blue", "#1D1D75"],
          ["Jaune maïs", "Maize", "#FFED6E"],
          ["Jaune ambre", "Ambre", "#CF9700"],
          ["Violet Aubergine", "Eggplant", "#5F4354"]
         ]
colors.each do |color|
  Color.create!(name_fr: color[0], name_eng: color[1], hexadecimal_code: color[2])
end



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

p = Planning.first

puts "4 - Creating colors"
puts ""




puts "5 - Creating roles"
puts ""

Role.create!(name: "vendeur",
            color_id: Color.find_by(name_fr: "Bleu ciel couvert").id
            )
Role.create!(name: "mécano",
            color_id: Color.find_by(name_fr: "Rose framboise").id
            )
Role.create!(name: "barista",
            color_id: Color.find_by(name_fr: "Or las-vegas").id
            )
Role.create!(name: "patron",
            color_id: Color.find_by(name_fr: "Brun castor").id
            )

# un-assigned value : color_role


puts "6 - Creating users (aka team members)"
puts ""



User.create!(email: "pierre@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "pierre",
            last_name: "kimousse",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_2m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "paul@boutique.com",
            working_hours: 37,
            is_owner: false,
            first_name: "paul",
            last_name: "ochon",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_3m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "jacques@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "jacques",
            last_name: "leventreur",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_7m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "jeannie@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "jeannie",
            last_name: "ouininon",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_4f.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "nelson@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "nelson",
            last_name: "monfaible",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_10m.jpeg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "bob@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "bob",
            last_name: "sponge",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_11m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "michel@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "michel",
            last_name: "jaxon",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_13m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "axel@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "axel",
            last_name: "rouge",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_15m.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "valentine@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "valentine",
            last_name: "cupide",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_5f.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "emma@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "emma",
            last_name: "reseille",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_6f.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "hortense@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "hortense",
            last_name: "Ya",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_8f.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "joseth@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "joseth",
            last_name: "La Chaussette",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_9f.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "magalie@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "magalie",
            last_name: "turgie",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_12f.jpeg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )
User.create!(email: "arielle@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "arielle",
            last_name: "la petite sirene",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_14f.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )

# cree user "no solution" pour le cas où pas de solution pour le slot
User.create!(email: "wtf@boutique.com",
            working_hours: 32,
            is_owner: false,
            first_name: "no solution",
            last_name: "atol",
            password: "password",
            profile_picture: open_image("./images_seeds/avatar_no.jpg"),
            invitation_created_at: time_with_zone,
            invitation_sent_at: time_with_zone,
            invitation_accepted_at: time_with_zone
  )


puts "7 - assigning roles to members"
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



puts "8 - assigning constraints to members"
puts ""

# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-06 08:00",
                  end_at: "2017-09-06 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-11 16:00",
                  end_at: "2017-09-11 22:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-12 16:00",
                  end_at: "2017-09-12 22:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-13 16:00",
                  end_at: "2017-09-13 22:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-14 16:00",
                  end_at: "2017-09-14 22:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-15 16:00",
                  end_at: "2017-09-15 22:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-09-27 08:00",
                  end_at: "2017-09-27 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-04 08:00",
                  end_at: "2017-10-04 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-11 08:00",
                  end_at: "2017-10-11 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-18 08:00",
                  end_at: "2017-10-18 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )
# pierre mercredi matin septembre octobre
Constraint.create!(start_at: "2017-10-24 08:00",
                  end_at: "2017-10-24 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "preference"
                  )


# pierre lundi matin
Constraint.create!(start_at: "2017-09-11 16:00",
                  end_at: "2017-09-11 22:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "maladie"
                  )
# pierre jeudi matin
Constraint.create!(start_at: "2017-09-14 08:00",
                  end_at: "2017-09-14 12:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "maladie"
                  )

# pierre vendredi matin
Constraint.create!(start_at: "2017-09-15 08:00",
                  end_at: "2017-09-15 18:00",
                  user_id: User.find_by_first_name('pierre').id,
                  category: "conge_annuel"
                  )
# emma lundi matin
Constraint.create!(start_at: "2017-09-12 08:00",
                  end_at: "2017-09-12 12:00",
                  user_id: User.find_by_first_name('emma').id,
                  category: "maladie"
                  )
# emma jeudi matin
Constraint.create!(start_at: "2017-09-13 08:00",
                  end_at: "2017-09-13 12:00",
                  user_id: User.find_by_first_name('emma').id,
                  category: "maladie"
                  )
# bob lundi matin
Constraint.create!(start_at: "2017-09-11 08:00",
                  end_at: "2017-09-11 12:00",
                  user_id: User.find_by_first_name('bob').id,
                  category: "preference"
                  )
# bob jeudi matin
Constraint.create!(start_at: "2017-09-14 08:00",
                  end_at: "2017-09-14 12:00",
                  user_id: User.find_by_first_name('bob').id,
                  category: "preference"
                  )

# bobvendredi matin
Constraint.create!(start_at: "2017-09-15 08:00",
                  end_at: "2017-09-15 12:00",
                  user_id: User.find_by_first_name('bob').id,
                  category: "preference"
                  )
Constraint.create!(start_at: "2017-09-03 08:00",
                  end_at: "2017-09-03 12:00",
                  user_id: User.find_by_first_name('bob').id,
                  category: "preference"
                  )
Constraint.create!(start_at: "2017-09-05 08:00",
                  end_at: "2017-09-05 12:00",
                  user_id: User.find_by_first_name('bob').id,
                  category: "preference"
                  )
Constraint.create!(start_at: "2017-09-01 08:00",
                  end_at: "2017-09-01 12:00",
                  user_id: User.find_by_first_name('bob').id,
                  category: "preference"
                  )



puts "9 - assigning teams to members"
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

puts "10 - adding SLOTS to planning + solution"
puts ""

p = Planning.first # equals planning of week 37
p35 = Planning.find_by_week_number(35)
p36 = Planning.find_by_week_number(36)


##11/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 08:00",
  end_at: "2017-09-11 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 08:00",
  end_at: "2017-09-11 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

# 2
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 20:00",
  role_id: Role.find_by_name("mécano").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
# 3
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 10:00",
  end_at: "2017-09-11 14:00",
  role_id: Role.find_by_name("vendeur").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 10:00",
  end_at: "2017-09-11 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 10:00",
  end_at: "2017-09-11 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )

#4
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 15:00",
  end_at: "2017-09-11 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 14:00",
  end_at: "2017-09-11 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )

#5
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-11 08:00",
  end_at: "2017-09-11 15:30",
  role_id: Role.find_by_name("barista").id,
  )

##############12/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 08:00",
  end_at: "2017-09-12 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 08:00",
  end_at: "2017-09-12 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

#7
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 14:00",
  end_at: "2017-09-12 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 14:00",
  end_at: "2017-09-12 20:00",
  role_id: Role.find_by_name("mécano").id,
  )

#8
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 10:00",
  end_at: "2017-09-12 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 10:00",
  end_at: "2017-09-12 14:00",
  role_id: Role.find_by_name("vendeur").id,
  )
#9
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 14:00",
  end_at: "2017-09-12 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 15:00",
  end_at: "2017-09-12 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )

#10
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-12 8:00",
  end_at: "2017-09-12 15:30",
  role_id: Role.find_by_name("barista").id,
  )
#### 13/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 08:00",
  end_at: "2017-09-13 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 08:00",
  end_at: "2017-09-13 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

#12
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 14:00",
  end_at: "2017-09-13 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-13 14:00",
  end_at: "2017-09-13 20:00",
  role_id: Role.find_by_name("mécano").id,
  )

#16
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 08:00",
  end_at: "2017-09-14 14:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 08:00",
  end_at: "2017-09-14 14:00",
  role_id: Role.find_by_name("mécano").id,
  )

#
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 14:00",
  end_at: "2017-09-14 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 14:00",
  end_at: "2017-09-14 20:00",
  role_id: Role.find_by_name("mécano").id,
  )

#18
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 10:00",
  end_at: "2017-09-14 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )

#19
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 10:00",
  end_at: "2017-09-14 14:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 14:00",
  end_at: "2017-09-14 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 15:00",
  end_at: "2017-09-14 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )
#20
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-14 08:00",
  end_at: "2017-09-14 15:30",
  role_id: Role.find_by_name("barista").id,
  )

#### 15/09

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 08:00",
  end_at: "2017-09-15 14:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 08:00",
  end_at: "2017-09-15 14:00",
  role_id: Role.find_by_name("mécano").id,
  )
#22
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 14:00",
  end_at: "2017-09-15 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 14:00",
  end_at: "2017-09-15 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
#23
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 10:00",
  end_at: "2017-09-15 14:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 10:00",
  end_at: "2017-09-15 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )
#24
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 15:00",
  end_at: "2017-09-15 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 14:00",
  end_at: "2017-09-15 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-15 8:00",
  end_at: "2017-09-15 15:30",
  role_id: Role.find_by_name("barista").id,
  )

#### 16/09 Samedi Grosse journée

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 08:00",
  end_at: "2017-09-16 14:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 08:00",
  end_at: "2017-09-16 14:00",
  role_id: Role.find_by_name("mécano").id,
  )
#27
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 20:00",
  role_id: Role.find_by_name("mécano").id,
  )
#28
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 10:00",
  end_at: "2017-09-16 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 10:00",
  end_at: "2017-09-16 13:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 10:00",
  end_at: "2017-09-16 14:00",
  role_id: Role.find_by_name("vendeur").id,
  )
#29
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )
Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 14:00",
  end_at: "2017-09-16 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 15:00",
  end_at: "2017-09-16 18:00",
  role_id: Role.find_by_name("vendeur").id,
  )


### Barista a trop travaillé

Slot.create!(
  planning_id: p.id,
  start_at: "2017-09-16 8:00",
  end_at: "2017-09-16 15:30",
  role_id: Role.find_by_name("barista").id,
  )

Slot.create!(
  planning_id: p35.id,
  start_at: "2017-08-28 07:00",
  end_at: "2017-08-28 15:00",
  role_id: Role.find_by_name("mécano").id,
  )

Slot.create!(
  planning_id: p36.id,
  start_at: "2017-09-4 07:00",
  end_at: "2017-09-4 15:00",
  role_id: Role.find_by_name("mécano").id,
  )

puts "11 - 2 new slots on planning n°18 to test slotgroups"

Slot.create!(
  planning_id: Planning.find_by(week_number: 35).id,
  start_at: "2017-08-29 07:00",
  end_at: "2017-08-29 15:00",
  role_id: Role.find_by_name("barista").id,
  )

Slot.create!(
  planning_id: Planning.find_by(week_number: 35).id,
  start_at: "2017-08-29 07:00",
  end_at: "2017-08-29 15:00",
  role_id: Role.find_by_name("barista").id,
  )


puts ""
puts  "  >> #{User.count} users created"
puts  "  >> #{Role.count} roles created"
puts  "  >> #{Color.count} colors created"
puts  "  >> #{Team.count} orders created"
puts  "  >> #{Slot.count} slots created"
puts  "  >> #{Planning.count} planning created (for week 37)"
puts  "  >> #{Constraint.count} constraints created"
puts ""
puts "---------------------------------"
puts "       SEEDING COMPLETED         "
puts "---------------------------------"



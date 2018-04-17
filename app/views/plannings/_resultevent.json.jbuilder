# rubocop:disable LineLength
json.extract! slot, :id, :role_id, :created_at, :updated_at, :planning_id
json.start slot.start_at
json.end slot.end_at
json.title slot.role.name
json.color Color.find(slot.role.color_id).hexadecimal_code
json.nombre planning_count_people_on_similar_slot(planning, slot)
json.user_id  solution_slot_user_id
json.picture  'http://res.cloudinary.com/dksqsr3pd/image/upload/c_fill,r_60,w_60/' + User.find(solution_slot_user_id).profile_picture.path
# rubocop:enable LineLength

json.extract! slot, :id, :role_id, :created_at, :updated_at, :planning_id
json.start slot.start_at
json.end slot.end_at
json.title slot.role.name
json.color slot.role.role_color
json.nombre planning_count_people_on_similar_slot(planning, slot)
json.user_id  slot.user_id
json.picture  "http://res.cloudinary.com/dksqsr3pd/image/upload/c_fill,r_60,w_60/" + User.find(slot.user_id).profile_picture.path

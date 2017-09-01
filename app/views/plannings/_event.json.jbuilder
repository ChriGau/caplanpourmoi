json.extract! slot, :id, :role_id, :created_at, :updated_at, :planning_id
json.start slot.start_at
json.end slot.end_at
json.title slot.role.name
json.color slot.role.role_color
json.nombre planning_count_people_on_similar_slot(planning, slot)

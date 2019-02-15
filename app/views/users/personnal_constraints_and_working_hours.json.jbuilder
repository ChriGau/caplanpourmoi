json.array! @constraints_array do |constraint|
  # json.partial! 'users/personnal_constraint', constraint: constraint
  json.extract! constraint, :id, :user_id, :start, :end, :title, :color
end

json.array! @slots do |slot|
  # json.partial! 'plannings/event', planning: @planning, slot: slot
  json.extract! slot, :id, :role_id, :planning_id, :end_at
  json.start slot.start_at
  json.end slot.end_at
  json.color Color.find(slot.role.color_id).hexadecimal_code
  json.title "working_hours"
end

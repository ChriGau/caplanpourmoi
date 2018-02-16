if !@solution.nil?
  json.array! @planning.slots do |slot|
    json.partial! 'plannings/resultevent', planning: @planning, slot: slot, solution_slot_user_id: slot.get_solution_slot(@solution).user.id
  end
else
  json.array! @planning.slots do |slot|
    json.partial! 'plannings/resultevent', planning: @planning, slot: slot, solution_slot_user_id: User.find_by(first_name: 'no solution')
  end
end


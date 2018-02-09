if @planning.solutions.chosen.exists?
  json.array! @planning.slots do |slot|
    json.partial! 'plannings/resultevent', planning: @planning, slot: slot, solution_slot_user_id: slot.get_chosen_solution_slot.user.id
  end
else
  json.array! @planning.slots do |slot|
    json.partial! 'plannings/resultevent', planning: @planning, slot: slot, solution_slot_user_id: User.find_by(first_name: 'no solution')
  end
end


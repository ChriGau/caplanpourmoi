# si on veut afficher une solution qui ne correspond pas au skeleton actuel
if !@solution.nil? && @solution.solution_slots.count != @planning.slots.count
  json.array! @solution.slots do |slot|
    json.partial! 'plannings/resultevent',
      planning: @solution.planning,
      slot: slot,
      solution_slot_id: slot.get_solution_slot(@solution),
      solution_slot_user_id: slot.get_solution_slot(@solution).user_id
  end
elsif !@solution.nil?
  json.array! @planning.slots do |slot|
    json.partial! 'plannings/resultevent',
      planning: @planning,
      slot: slot,
      solution_slot_id: slot.get_solution_slot(@solution),
      solution_slot_user_id: slot.get_solution_slot(@solution).user_id
  end
else
  json.array! @planning.slots do |slot|
    json.partial! 'plannings/resultevent',
      planning: @planning,
      slot: slot,
      solution_slot_id: slot.get_solution_slot(@solution),
      solution_slot_user_id: User.find_by(first_name: 'no solution')
  end
end

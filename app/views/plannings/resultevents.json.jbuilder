
json.array! @planning.slots do |slot|
  json.partial! 'plannings/resultevent', planning: @planning, slot: slot, solution_slot: slot.get_chosen_solution_slot
end

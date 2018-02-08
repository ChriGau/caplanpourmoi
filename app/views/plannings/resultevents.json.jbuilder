
json.array! @planning.slots do |slot|
  json.partial! 'plannings/resultevent', planning: @planning, slot: slot, solution_slot: SolutionSlot.select{ |x| x.solution.chosen? && x.slot == slot }.first
end

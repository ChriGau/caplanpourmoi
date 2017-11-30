json.array! @planning.slots do |slot|
  json.partial! 'plannings/event', planning: @planning, slot: slot
end

json.array! @constraints_array do |constraint|
  json.partial! 'users/personnal_constraint', constraint: constraint
end

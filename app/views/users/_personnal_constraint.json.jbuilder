json.extract! constraint, :id, :user_id, :start, :end, :title
if constraint[:title] == "preference"
  json.color Color.find_by(name_fr: "Bleu nuit").hexadecimal_code
  elsif constraint[:title] == "conge_annuel"
    json.color Color.find_by(name_fr: "Violet Aubergine").hexadecimal_code
  else
    json.color Color.find_by(name_fr: "Rose framboise").hexadecimal_code
end
# json.color Color.find(constraint.role.color_id).hexadecimal_code

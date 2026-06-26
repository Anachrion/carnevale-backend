json.partial! "api/v1/lists/list", list: @list

json.entries @list.list_entries.order(:position) do |entry|
  json.position entry.position
  json.reference_id entry.reference_id
  json.name entry.reference.name
  json.cost entry.reference.cost
end

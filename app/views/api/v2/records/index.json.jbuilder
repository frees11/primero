# frozen_string_literal: true

json.data do
  json.array! @records do |record|
    json.partial! 'api/v2/records/record', record:, selected_field_names: @selected_field_names
  end
end

json.metadata do
  json.total @total
  json.per @per
  json.page @page
end

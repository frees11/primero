def create_or_update_lookup(lookup_hash)
  lookup_id = Lookup.lookup_id_from_name lookup_hash[:name]
  lookup = Lookup.get lookup_id

  if lookup.nil?
    puts "Creating lookup #{lookup_id}"
    Lookup.create! lookup_hash
  else
    puts "Updating lookup #{lookup_id}"
    lookup.update_attributes lookup_hash
  end

end



create_or_update_lookup(
  :name => "country",
  :lookup_values => [
    "Country1",
    "Country2",
    "Country3",
    "Country4",
    "Country5",
    "Country6",
    "Country7",
    "Country8",
    "Country9",
    "Country10"
  ]
)

create_or_update_lookup(
  :name => "nationality",
  :lookup_values => [
    "Nationality1",
    "Nationality2",
    "Nationality3",
    "Nationality4",
    "Nationality5",
    "Nationality6",
    "Nationality7",
    "Nationality8",
    "Nationality9",
    "Nationality10"
  ]
)

create_or_update_lookup(
  :name => "ethnicity",
  :lookup_values => [
    "Ethnicity1",
    "Ethnicity2",
    "Ethnicity3",
    "Ethnicity4",
    "Ethnicity5",
    "Ethnicity6",
    "Ethnicity7",
    "Ethnicity8",
    "Ethnicity9",
    "Ethnicity10"
  ]
)

create_or_update_lookup(
  :name => "language",
  :lookup_values => [
    "Language1",
    "Language2",
    "Language3",
    "Language4",
    "Language5",
    "Language6",
    "Language7",
    "Language8",
    "Language9",
    "Language10"
  ]
)

create_or_update_lookup(
  :name => "religion",
  :lookup_values => [
    "Religion1",
    "Religion2",
    "Religion3",
    "Religion4",
    "Religion5",
    "Religion6",
    "Religion7",
    "Religion8",
    "Religion9",
    "Religion10"
  ]
)
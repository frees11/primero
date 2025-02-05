# frozen_string_literal: true

#########################################
# Tracing action subform

tracing_action_subform = [
  Field.new('name' => 'date_tracing',
            'type' => 'date_field',
            'display_name_en' => 'Date of tracing'),
  Field.new('name' => 'tracing_type',
            'type' => 'select_box',
            'display_name_en' => 'Type of action taken',
            'option_strings_text_en' => [
              { id: 'case_by_case_tracing', display_text: 'Case by Case Tracing' },
              { id: 'individual_tracing', display_text: 'Individual Tracing' },
              { id: 'mass_tracing', display_text: 'Mass Tracing' },
              { id: 'photo_tracing', display_text: 'Photo Tracing' },
              { id: 'referral_to_ngo', display_text: 'Referral to NGO' },
              { id: 'referral_to_icrc', display_text: 'Referral to ICRC' }
            ].map(&:with_indifferent_access)),
  Field.new('name' => 'address_tracing',
            'type' => 'textarea',
            'display_name_en' => 'Address/Village where the tracing action took place'),
  Field.new('name' => 'location_tracing',
            'type' => 'select_box',
            'display_name_en' => 'Location of Tracing',
            'option_strings_source' => 'Location'),
  Field.new('name' => 'tracing_action_description',
            'type' => 'text_field',
            'display_name_en' => 'Action taken and remarks'),
  Field.new('name' => 'tracing_outcome',
            'type' => 'select_box',
            'display_name_en' => 'Outcome of tracing action',
            'option_strings_text_en' => [
              { id: 'pending', display_text: 'Pending' },
              { id: 'successful', display_text: 'Successful' },
              { id: 'unsuccessful', display_text: 'Unsuccessful' },
              { id: 'yes', display_text: 'Yes' }
            ].map(&:with_indifferent_access))
]

FormSection.create_or_update!(
  'visible' => false,
  'is_nested' => true,
  :order_form_group => 130,
  :order => 20,
  :order_subform => 2,
  :unique_id => 'tracing_actions_section',
  :parent_form => 'case',
  'editable' => true,
  :fields => tracing_action_subform,
  :initial_subforms => 0,
  'name_en' => 'Nested Tracing Action',
  'description_en' => 'Tracing Action Subform',
  'collapsed_field_names' => %w[tracing_type date_tracing]
)

#########################################
# Tracing form

tracing_fields = [
  Field.new('name' => 'matched_tracing_request_id',
            'type' => 'text_field',
            'editable' => false,
            'disabled' => true,
            'link_to_path' => 'tracing_request',
            'display_name_en' => 'Matched Tracing Request ID'),
  Field.new('name' => 'separation_separator',
            'type' => 'separator',
            'display_name_en' => 'Separation History'),
  Field.new('name' => 'tracing_status',
            'type' => 'select_box',
            'display_name_en' => 'Tracing Status',
            'option_strings_source' => 'lookup lookup-tracing-status'),
  Field.new('name' => 'date_of_separation',
            'type' => 'date_field',
            'display_name_en' => 'Date of Separation',
            'matchable' => true),
  Field.new('name' => 'separation_cause',
            'type' => 'select_box',
            'display_name_en' => 'What was the main cause of separation?',
            'option_strings_source' => 'lookup lookup-separation-cause',
            'matchable' => true),
  Field.new('name' => 'separation_cause_other',
            'type' => 'text_field',
            'display_name_en' => 'If Other, please specify',
            'matchable' => true),
  Field.new('name' => 'location_separation',
            'type' => 'select_box',
            'display_name_en' => 'Separation Location',
            'option_strings_source' => 'Location',
            'matchable' => true)
]

FormSection.create_or_update!(
  :unique_id => 'tracing',
  :parent_form => 'case',
  'visible' => false,
  :order_form_group => 130,
  :order => 20,
  :order_subform => 0,
  :form_group_id => 'tracing',
  :fields => tracing_fields,
  'editable' => true,
  'name_en' => 'Tracing',
  'description_en' => 'Tracing'
)

# frozen_string_literal: true

fields = [
  Field.new({ 'name' => 'record_state',
              'type' => 'tick_box',
              'editable' => false,
              'disabled' => true,
              'display_name_en' => 'Valid Record?' }),
  Field.new({ 'name' => 'owned_by_agency_id',
              'type' => 'select_box',
              'display_name_en' => "Record Owner's Agency",
              'editable' => false,
              'disabled' => true,
              'option_strings_source' => 'Agency' }),
  Field.new({ 'name' => 'owned_by_location',
              'type' => 'select_box',
              'display_name_en' => "Record Owner's Location",
              'editable' => false,
              'disabled' => true,
              'option_strings_source' => 'Location' }),
  Field.new({ 'name' => 'has_case_plan',
              'type' => 'tick_box',
              'display_name_en' => 'Does this case have a case plan?',
              'editable' => false,
              'disabled' => true }),
  Field.new({ 'name' => 'workflow',
              'type' => 'select_box',
              'display_name_en' => 'Workflow Status',
              'editable' => false,
              'disabled' => true,
              'option_strings_source' => 'lookup lookup-workflow' })
]

FormSection.create_or_update!({
                                unique_id: 'other_reportable_fields_case',
                                parent_form: 'case',
                                visible: false,
                                order: 1000,
                                order_form_group: 1000,
                                form_group_id: 'other_reportable_fields',
                                editable: true,
                                fields:,
                                name_en: 'Other Reportable Fields',
                                description_en: 'Other Reportable Fields'
                              })

# frozen_string_literal: true

followup_subform_fields = [
  Field.new('name' => 'followup_type',
            'type' => 'select_box',
            'display_name_en' => 'Type of follow up',
            'option_strings_source' => 'lookup lookup-followup-type'),
  Field.new('name' => 'followup_service_type',
            'type' => 'select_box',
            'display_name_en' => 'Type of service',
            'option_strings_source' => 'lookup lookup-service-type'),
  Field.new('name' => 'followup_assessment_type',
            'type' => 'select_box',
            'display_name_en' => 'Type of assessment',
            'option_strings_text_en' => [
              { id: 'personal_intervention_assessment', display_text: 'Personal Intervention Assessment' },
              { id: 'medical_intervention_assessment', display_text: 'Medical Intervention Assessment' },
              { id: 'family_intervention_assessment', display_text: 'Family Intervention Assessment' },
              { id: 'community_intervention_assessment', display_text: 'Community Intervention Assessment' },
              { id: 'unhcr_intervention_assessment', display_text: 'UNHCR Intervention Assessment' },
              { id: 'ngo_intervention_assessment', display_text: 'NGO Intervention Assessment' },
              { id: 'economic_intervention_assessment', display_text: 'Economic Intervention Assessment' },
              { id: 'education_intervention_assessment', display_text: 'Education Intervention Assessment' },
              { id: 'health_intervention_assessment', display_text: 'Health Intervention Assessment' },
              { id: 'other_intervention_assessment', display_text: 'Other Intervention Assessment' }
            ].map(&:with_indifferent_access)),
  Field.new('name' => 'protection_concern_type',
            'type' => 'select_box',
            'visible' => false,
            'display_name_en' => 'Type of Protection Concern ',
            'option_strings_source' => 'lookup lookup-protection-concerns'),
  Field.new('name' => 'followup_needed_by_date',
            'type' => 'date_field',
            'display_name_en' => 'Follow up needed by'),
  Field.new('name' => 'followup_date',
            'type' => 'date_field',
            'display_name_en' => 'Follow up date'),
  Field.new('name' => 'followup_comments',
            'type' => 'text_field',
            'display_name_en' => 'Comments')
]

followup_subform_section = FormSection.create_or_update!(
  'visible' => false,
  'is_nested' => true,
  :order_form_group => 110,
  :order => 20,
  :order_subform => 1,
  :unique_id => 'followup_subform_section',
  :parent_form => 'case',
  'editable' => true,
  :fields => followup_subform_fields,
  :initial_subforms => 0,
  'name_en' => 'Nested Followup Subform',
  'description_en' => 'Nested Followup Subform',
  'collapsed_field_names' => %w[followup_date followup_type]
)

followup_fields = [
  Field.new('name' => 'followup_subform_section',
            'type' => 'subform', 'editable' => true,
            'subform_section' => followup_subform_section,
            'display_name_en' => 'Follow Up',
            'subform_sort_by' => 'followup_date')
]

FormSection.create_or_update!(
  :unique_id => 'followup',
  :parent_form => 'case',
  'visible' => true,
  :order_form_group => 110,
  :order => 20,
  :order_subform => 0,
  :form_group_id => 'services_follow_up',
  'editable' => true,
  :fields => followup_fields,
  'name_en' => 'Follow Up',
  'description_en' => 'Follow Up'
)

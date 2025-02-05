# frozen_string_literal: true

consent_fields = [
  Field.new('name' => 'interview_subject',
            'type' => 'select_box',
            'display_name_en' => 'Consent Obtained From',
            'option_strings_text_en' => [
              { id: 'individual', display_text: 'Individual' },
              { id: 'caregiver', display_text: 'Caregiver' },
              { id: 'other', display_text: 'Other (please specify)' }
            ].map(&:with_indifferent_access)),
  Field.new('name' => 'consent_source_other',
            'type' => 'text_field',
            'display_name_en' => 'If Other, please specify'),
  Field.new('name' => 'consent_for_services',
            'type' => 'tick_box',
            'tick_box_label_en' => 'Yes',
            'display_name_en' => 'Consent has been obtained for the child to receive case management services',
            'help_text' => 'This includes consent for sharing information with other organizations providing services'),
  Field.new('name' => 'consent_reporting',
            'type' => 'radio_button',
            'display_name_en' => 'Consent is given share non-identifiable information for reporting',
            'option_strings_source' => 'lookup lookup-yes-no'),
  Field.new('name' => 'consent_for_tracing',
            'type' => 'radio_button',
            'display_name_en' => 'Consent has been obtained to disclose information for tracing purposes',
            'option_strings_source' => 'lookup lookup-yes-no',
            'help_text' => "If this field is 'No', the child's case record will not show up in Matches with Inquirer"\
                          'Tracing Requests.',
            'visible' => false),
  Field.new('name' => 'disclosure_other_orgs',
            'type' => 'tick_box',
            'tick_box_label_en' => 'Yes',
            'display_name_en' => 'The individual providing consent agrees to share collected information with other '\
                                  'organizations for service provision?',
            'help_text' => 'This includes sharing information with other oranizations providing services.'),
  Field.new('name' => 'consent_share_separator',
            'type' => 'separator',
            'display_name_en' => 'Consent Details for Sharing Information'),
  Field.new('name' => 'consent_info_sharing',
            'type' => 'select_box',
            'display_name_en' => 'Consent has been given to share the information collected with',
            'multi_select' => true,
            'visible' => false,
            'option_strings_text_en' => [
              { id: 'family', display_text: 'Family' }.with_indifferent_access,
              { id: 'authorities', display_text: 'Authorities' }.with_indifferent_access,
              { id: 'unhcr', display_text: 'UNHCR' }.with_indifferent_access,
              { id: 'other_organizations', display_text: 'Other Organizations' }.with_indifferent_access,
              { id: 'others', display_text: 'Others, please specify' }.with_indifferent_access
            ]),
  Field.new('name' => 'consent_info_sharing_others',
            'type' => 'text_field',
            'display_name_en' => 'If information can be shared with others, please specify who',
            'visible' => false),
  Field.new('name' => 'disclosure_deny_details',
            'type' => 'text_field',
            'display_name_en' => 'What information should be withheld from a particular person or individual'),
  Field.new('name' => 'withholding_info_reason',
            'type' => 'select_box',
            'display_name_en' => 'Reason for withholding information',
            'multi_select' => true,
            'option_strings_text_en' => [
              { id: 'fear', display_text: 'Fear of harm to themselves or others' }.with_indifferent_access,
              {
                id: 'communicate_information',
                display_text: 'Want to communicate information themselves'
              }.with_indifferent_access,
              { id: 'others', display_text: 'Other reason, please specify' }.with_indifferent_access
            ]),
  Field.new('name' => 'withholding_info_other_reason',
            'type' => 'text_field',
            'display_name_en' => 'If other reason for withholding information, please specify'),
  Field.new('name' => 'unhcr_export_opt_in',
            'type' => 'tick_box',
            'tick_box_label_en' => 'Yes',
            'display_name_en' => 'The individual providing consent agrees to share information about this case with '\
                                  'UNHCR for the purposes of refugee protection case management.',
            'editable' => false,
            'visible' => false),
  Field.new('name' => 'legitimate_basis',
            'type' => 'select_box',
            'display_name_en' => 'Reasons for collecting and retaining information on this Case',
            'multi_select' => true,
            'visible' => false,
            'mobile_visible' => true,
            'option_strings_source' => 'lookup lookup-legitimate-basis',
            'guiding_questions_en': [
              '(1) The consent of the data subject, or the child’s representative where appropriate ("consent").',
              '(2) To prepare for or perform a contract with the data subject, '\
              'including a contract of employment ("contract").',
              '(3) To protect the life, physical or mental integrity of the data subject or another person '\
              '("vital interests").',
              '(4) To protect or advance the interests of people UNICEF serves, and particularly those interests '\
              'UNICEF is mandated to protect or advance ("beneficiary interests").',
              '(5) Compliance with a public legal obligation to which UNICEF is subject ("legal obligation").',
              '(6) Other legitimate interests of UNICEF consistent with its mandate, including the establishment, '\
              'exercise or defense of legal claims or for UNICEF accountability ("other legitimate interests").'
            ].join("\n"))
]

FormSection.create_or_update!(
  :unique_id => 'consent',
  :parent_form => 'case',
  'visible' => true,
  :order_form_group => 40,
  :order => 10,
  :order_subform => 0,
  :form_group_id => 'data_confidentiality',
  'editable' => true,
  :fields => consent_fields,
  'name_en' => 'Data Confidentiality',
  'description_en' => 'Data Confidentiality',
  :mobile_form => true
)

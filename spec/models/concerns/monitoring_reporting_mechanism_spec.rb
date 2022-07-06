# frozen_string_literal: true

require 'rails_helper'

describe MonitoringReportingMechanism, search: true do
  let(:incident_1) do
    Incident.create!(
      data: { incident_date: '2022-04-08' },
      violations: [
        Violation.new(data: { type: 'killing', ctfmr_verified: 'verified' })
      ]
    )
  end

  let(:incident_2) do
    Incident.create!(
      violations: [
        Violation.new(data: { type: 'killing', ctfmr_verified: 'not_mrm' }),
        Violation.new(data: { type: 'maiming', ctfmr_verified: 'report_pending_verification' })
      ]
    )
  end

  before do
    clean_data(Incident, Violation)
    incident_1
    incident_2
    Incident.reindex
    Sunspot.commit
  end

  it 'can find an incident with a violation of type killing and verified' do
    search_result = SearchService.search(
      Incident,
      filters: [
        SearchFilters::Value.new(field_name: 'killing_verified', value: 'true')
      ]
    ).results
    expect(search_result.size).to eq(1)
    expect(search_result.first.id).to eq(incident_1.id)
  end

  it 'can find an incident with a violation of type maiming and report_pending_verification' do
    search_result = SearchService.search(
      Incident,
      filters: [
        SearchFilters::Value.new(field_name: 'maiming_report_pending_verification', value: 'true')
      ]
    ).results
    expect(search_result.size).to eq(1)
    expect(search_result.first.id).to eq(incident_2.id)
  end
end

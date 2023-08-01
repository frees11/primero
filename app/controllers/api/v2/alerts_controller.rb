# frozen_string_literal: true

# Class for Alert Controller
class Api::V2::AlertsController < Api::V2::RecordResourceController
  def bulk_index
    @alerts = {
      case: Child.alert_count(current_user),
      incident: Incident.alert_count(current_user),
      tracing_request: TracingRequest.alert_count(current_user)
    }
  end

  def index
    authorize! :read, @record
    @alerts = @record.alerts
  end

  def index_action_message
    'show_alerts'
  end
end

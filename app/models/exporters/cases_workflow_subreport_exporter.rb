# frozen_string_literal: true

# Class to export CasesWorkflows
# Note: Insight (managed report) exporter names are implicitly derived from the insight name.
# See Exporters::ManagedReportExporter#subreport_exporter_class
class Exporters::CasesWorkflowSubreportExporter < Exporters::RecordWorkflowSubreportExporter
end

# frozen_string_literal: true

require 'csv'

# Exports the top level fields of a record to a flat CSV
class Exporters::CsvExporter < Exporters::BaseExporter
  EXCLUDED_TYPES = [
    Field::PHOTO_UPLOAD_BOX, Field::AUDIO_UPLOAD_BOX,
    Field::DOCUMENT_UPLOAD_BOX, Field::SUBFORM, Field::SEPARATOR
  ].freeze

  class << self
    def id
      'csv'
    end

    def supported_models
      [Child, Incident, TracingRequest, RegistryRecord, Family]
    end

    def excluded_field_names
      Field.where(type: EXCLUDED_TYPES).pluck(:name)
    end
  end

  def export(records)
    csv_export = CSVSafe.generate do |rows|
      rows << headers if @called_first_time.nil?
      @called_first_time ||= true

      records.each do |record|
        rows << row(record, fields)
      end
    end
    buffer.write(csv_export)
  end

  private

  def headers
    ['id'] + field_names
  end

  def row(record, fields)
    [record.id] + fields.map do |field|
      record.data[field.name]
    end
  end
end

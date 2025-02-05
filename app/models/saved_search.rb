# frozen_string_literal: true

# Class for Saved Search
class SavedSearch < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :primero_modules

  def self.new_with_user(user, data = {})
    SavedSearch.new(
      name: data[:name],
      record_type: data[:record_type],
      filters: data[:filters],
      primero_modules: PrimeroModule.where(unique_id: data[:module_ids]),
      user:
    )
  end

  def add_filter(filter)
    if filters.present?
      filters << filter
    else
      self.filters = [filter]
    end
  end
end

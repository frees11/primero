# frozen_string_literal: true

# Model for MRM GroupVictim
class GroupVictim < ApplicationRecord
  has_and_belongs_to_many :violations
end

# frozen_string_literal: true

class Chef < ApplicationRecord
  has_many :recipes, dependent: :nullify
end

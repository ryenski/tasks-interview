class User < ApplicationRecord
  has_secure_password

  scope :alphabetical, -> { order(:name) }
end

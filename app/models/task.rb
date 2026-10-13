class Task < ApplicationRecord
  belongs_to :assignee, class_name: "User", optional: true

  validates :title, presence: true
  validates :assignee, presence: true, if: -> { assignee_id.present? }

  scope :for_list, -> { includes(:assignee).order(:created_at) }
end

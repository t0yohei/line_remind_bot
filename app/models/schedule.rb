class Schedule < ApplicationRecord
  belongs_to :talk_room_type
  enum schedule_types:
    { specific_day: 0, daily: 1, weekly: 2,
      monthly: 3 }
  enum post_wdays:
    { Sunday: 0, Monday: 1, Tuesday: 2, Wednesday: 3,
      Thursday: 4, Friday: 5, Saturday: 6 }

  scope :active, -> { where(deleted: false, sent: false) }
  scope :inactive, -> { where(deleted: true).or(Schedule.where(sent: true)) }
end

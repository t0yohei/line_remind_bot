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

  def specific_day_schdules_now
    now = Time.zone.now
    Schedule.where(
      schedule_type: Schedule.active.schedule_types[:specific_day],
      post_year: now.year,
      post_month: now.mon,
      post_day: now.day,
      post_hour: now.hour,
      post_minute: now.min...(now.min + 10),
      deleted: false
    ).select(:title, :talk_room_type_id, :talk_room_id)
  end

  def daily_schdules_now
    now = Time.zone.now
    Schedule.where(
      schedule_type: Schedule.schedule_types[:daily],
      post_hour: now.hour,
      post_minute: now.min...(now.min + 10),
      deleted: false
    ).select(:title, :talk_room_type_id, :talk_room_id)
  end

  def weekly_schdules_now
    now = Time.zone.now
    Schedule.where(
      schedule_type: Schedule.schedule_types[:weekly],
      post_wday: now.wday,
      post_hour: now.hour,
      post_minute: now.min...(now.min + 10),
      deleted: false
    ).select(:title, :talk_room_type_id, :talk_room_id)
  end

  def monthly_schdules_now
    now = Time.zone.now
    Schedule.where(
      schedule_type: Schedule.schedule_types[:monthly],
      post_day: now.day,
      post_hour: now.hour,
      post_minute: now.min...(now.min + 10),
      deleted: false
    ).select(:title, :talk_room_type_id, :talk_room_id)
  end
end

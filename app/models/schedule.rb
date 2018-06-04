class Schedule < ApplicationRecord
  belongs_to :talk_room_type
  enum schedule_type:
    { specific_day: 'specific_day', everyday: 'everyday', everyweek: 'everyweek',
      everymonth: 'everymonth' }
  enum post_day:
    { Monday: 'Monday', Tuesday: 'Tuesday', Wednesday: 'Wednesday',
      Thursday: 'Thursday', Friday: 'Friday', Saturday: 'Saturday',
      Sunday: 'Sunday' }
end

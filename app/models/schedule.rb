class Schedule < ApplicationRecord
  belongs_to :talk_room_type
  enum schedule_types:
    { specific_day: 0, everyday: 1, everyweek: 2,
      everymonth: 3 }
  enum post_wdays:
    { Sunday: 0, Monday: 1, Tuesday: 2, Wednesday: 3,
      Thursday: 4, Friday: 5, Saturday: 6 }
end

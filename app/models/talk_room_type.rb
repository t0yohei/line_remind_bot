class TalkRoomType < ApplicationRecord
  has_many :schedule

  enum talk_room_type_id:
    { user: 0, room: 1, line_group: 2 }
end

require 'line/bot'

class Tasks::RegularMessage
  def self.remind_schedules
    schedules = select_schedules(Date.today, DateTime.now)
    post_schedules(schedules)
  end

  def select_schedules(date, datetime)
    schedules = []
    schedules = select_specific_day_schdules(date, datetime, schedules)
    # schedules = select_daily_schdules(date, schedules)
    # schedules = select_weekly_schdules(date, schedules)
    # schedules = select_monthly_schdules(date, schedules)
    return schedules
  end

  def select_specific_day_schdules(date, datetime, schedules)
    schedules << Schedule.where(schedule_type: 'specific_day', post_date: date, post_hour: datetime.hour, post_minute: datetime.minute).pluck(:title, :talk_room_type_id, :talk_room_id)
  end

  def select_daily_schdules(datetime, schedules)
    schedules << Schedule.where(schedule_type: 'everyday', post_hour: datetime.hour, post_minute: datetime.minute).pluck(:title, :talk_room_type_id, :talk_room_id)
  end

  def select_weekly_schdules(date, datetime, schedules)
    schedules << Schedule.where(schedule_type: 'everyweek', post_day: date.wday, post_hour: datetime.hour, post_minute: datetime.minute).pluck(:title, :talk_room_type_id, :talk_room_id)
  end

  def select_monthly_schdules(date, datetime, schedules)
    schedules << Schedule.where(schedule_type: 'everymonth', post_date: date, post_hour: datetime.hour, post_minute: datetime.minute).pluck(:title, :talk_room_type_id, :talk_room_id)
  end

  def self.post_schedules(schedules)
    schedule = ""
    message = {
      type: 'text',
      text: 'hello' + schedules
    }
    client ||= Line::Bot::Client.new { |config|
      config.channel_secret = Rails.application.secrets.LINE_CHANNEL_SECRET
      config.channel_token = Rails.application.secrets.LINE_CHANNEL_TOKEN
    }

    roomId = 'Cd577d339555fbc0e115d6e878b9cf0db'
    client.push_message(roomId, message)
  end

end

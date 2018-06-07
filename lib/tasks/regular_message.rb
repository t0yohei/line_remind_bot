require 'line/bot'

class Tasks::RegularMessage
  def self.remind_schedules
    schedules = select_schedules(Date.today, DateTime.now)
    post_schedules(schedules)
  end

  def select_schedules(date, datetime)
    schedules =[]
    schedules = select_specific_day_schdules(date, datetime, schedules)
    # schedules = select_daily_schdules(date, schedules)
    # schedules = select_weekly_schdules(date, schedules)
    # schedules = select_monthly_schdules(date, schedules)
    return schedules
  end

  def select_specific_day_schdules(date, datetime, schedules)
    # schedule = Schedule.where(post_data: date, post_time)
  end

  def select_daily_schdules(date, schedules)
  end

  def select_weekly_schdules(date, schedules)
  end

  def select_monthly_schdules(date, schedules)
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

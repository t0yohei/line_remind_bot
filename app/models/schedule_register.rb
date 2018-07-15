class ScheduleRegister
  include ActiveModel::Model

  class << self
    def create_schedule(event)
      schedule_info = get_schedule_info(event)
      case schedule_info[:post_data]
      when /\A[一1]日だけ*/
        create_specific_day_schedule(event, schedule_info)
      when /\A毎日*/
        create_daily_schedule(event, schedule_info)
      when /\A毎週*/
        create_weekly_schedule(event, schedule_info)
      when /\A毎月*/
        create_monthly_schedule(event, schedule_info)
      end
    end

    def delete_schedule(event)
      schedule_id = event.message['text'].sub(/削除/)
      target_schedule = Schedule.find_by_id(schedule_id)
      return false if target_schedule.nil?
      target_schedule.update_attribute(:deleted, true)
      true
    end

    def get_schedule_info(event)
      talk_room_type_id = TalkRoomType.find_by(
        type_name: event['source']['type']
      ).id
      target_id_type = TalkRoomType.find_by(
        id: talk_room_type_id
      ).target_id_type
      talk_room_id = event['source'][target_id_type]
      {
        post_data: event['postback']['data'],
        talk_room_type_id: target_id_type,
        talk_room_id: talk_room_id,
        create_user_id: event['source']['userId']
      }
    end

    def create_specific_day_schedule(event, schedule_info)
      post_date = Time.zone.parse(event['postback']['params']['datetime'])
      new_schedule = Schedule.new(
        title: schedule_info[:post_data].sub(/[一1]日だけ/),
        talk_room_type_id: schedule_info[:talk_room_type_id],
        talk_room_id: schedule_info[:talk_room_id],
        schedule_type: Schedule.schedule_types[:specific_day],
        post_year: post_date.year,
        post_month: post_date.mon,
        post_day: post_date.day,
        post_hour: post_date.hour,
        post_minute: post_date.min,
        create_user_id: schedule_info[:create_user_id]
      )
      return true if new_schedule.save
    end

    def create_daily_schedule(event)
      post_time = Time.zone.parse(event['postback']['params']['time'])
      new_schedule = Schedule.new(
        title: schedule_info[:post_data].sub(/毎日/),
        talk_room_type_id: schedule_info[:talk_room_type_id],
        talk_room_id: schedule_info[:talk_room_id],
        schedule_type: Schedule.schedule_types[:daily],
        post_hour: post_time.hour,
        post_minute: post_time.min,
        create_user_id: schedule_info[:create_user_id]
      )
      return true if new_schedule.save
    end

    def create_weekly_schedule(event)
      post_day = event['postback']['data'][-3, 3]
      post_wday = get_post_wday(post_day)
      post_time = Time.zone.parse(event['postback']['params']['time'])
      new_schedule = Schedule.new(
        title: schedule_info[:post_data].delete("\n毎週").delete('その他').delete(post_day),
        talk_room_type_id: schedule_info[:talk_room_type_id],
        talk_room_id: schedule_info[:talk_room_id],
        schedule_type: Schedule.schedule_types[:weekly],
        post_wday: post_wday,
        post_hour: post_time.hour,
        post_minute: post_time.min,
        create_user_id: schedule_info[:create_user_id]
      )
      return true if new_schedule.save
    end

    def create_monthly_schedule(event)
      post_date = Time.zone.parse(event['postback']['params']['datetime'])
      new_schedule = Schedule.new(
        title: schedule_info[:post_data].sub(/毎月/),
        talk_room_type_id: schedule_info[:talk_room_type_id],
        talk_room_id: schedule_info[:talk_room_id],
        schedule_type: Schedule.schedule_types[:monthly],
        post_day: post_date.day,
        post_hour: post_date.hour,
        post_minute: post_date.min,
        create_user_id: schedule_info[:create_user_id]
      )
      return true if new_schedule.save
    end

    def get_post_wday(post_day)
      case post_day
      when '日曜日'
        Schedule.post_wdays[:Sunday]
      when '月曜日'
        Schedule.post_wdays[:Monday]
      when '火曜日'
        Schedule.post_wdays[:Tuesday]
      when '水曜日'
        Schedule.post_wdays[:Wednesday]
      when '木曜日'
        Schedule.post_wdays[:Thursday]
      when '金曜日'
        Schedule.post_wdays[:Friday]
      when '土曜日'
        Schedule.post_wdays[:Saturday]
      end
    end
  end
end

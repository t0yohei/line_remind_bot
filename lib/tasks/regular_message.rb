require 'line/bot'

module Tasks
  class RegularMessage
    class << self
      def remind_schedules
        schedules = select_schedules(Time.zone.now)
        post_schedules(schedules)
      end

      def select_schedules(date)
        schedules = []
        schedules = select_specific_day_schdules(date, schedules)
        schedules = select_daily_schdules(date, schedules)
        schedules = select_weekly_schdules(date, schedules)
        schedules = select_monthly_schdules(date, schedules)
        schedules
      end

      def select_specific_day_schdules(date, schedules)
        schedules <<
          Schedule.where(
            schedule_type: Schedule.active.schedule_types[:specific_day],
            post_year: date.year,
            post_month: date.mon,
            post_day: date.day,
            post_hour: date.hour,
            post_minute: date.min...(date.min + 10)
          ).select(:title, :talk_room_type_id, :talk_room_id)
      end

      def select_daily_schdules(date, schedules)
        schedules <<
          Schedule.where(
            schedule_type: Schedule.schedule_types[:everyday],
            post_hour: date.hour,
            post_minute: date.min...(date.min + 10),
            deleted: false
          ).select(:title, :talk_room_type_id, :talk_room_id)
      end

      def select_weekly_schdules(date, schedules)
        schedules <<
          Schedule.where(
            schedule_type: Schedule.schedule_types[:everyweek],
            post_wday: date.wday,
            post_hour: date.hour,
            post_minute: date.min...(date.min + 10),
            deleted: false
          ).select(:title, :talk_room_type_id, :talk_room_id)
      end

      def select_monthly_schdules(date, schedules)
        schedules <<
          Schedule.where(
            schedule_type: Schedule.schedule_types[:everymonth],
            post_day: date.day,
            post_hour: date.hour,
            post_minute: date.min...(date.min + 10),
            deleted: false
          ).select(:title, :talk_room_type_id, :talk_room_id)
      end

      def post_schedules(schedules)
        client ||= Line::Bot::Client.new do |config|
          config.channel_secret = ENV['LINE_CHANNEL_SECRET']
          config.channel_token = ENV['LINE_CHANNEL_TOKEN']
        end

        schedules.each do |type_schedules|
          next if type_schedules.blank?

          # roop with schedule types
          type_schedules.each do |schedule|
            talk_room_id = schedule.talk_room_id
            message = {
              type: 'text',
              text: schedule.title
            }
            client.push_message(talk_room_id, message)
          end
        end
      end
    end
  end
end

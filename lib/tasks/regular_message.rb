require 'line/bot'

module Tasks
  class RegularMessage
    class << self
      def remind_schedules
        schedules = select_schedules
        post_schedules(schedules)
      end

      def select_schedules
        #schedule_typeごとに該当scheduleを配列に格納
        schedules = []
        schedules << Schedule.specific_day_schdules_now
        schedules << Schedule.daily_schdules_now
        schedules << Schedule.weekly_schdules_now
        schedules << Schedule.monthly_schdules_now
      end

      def post_schedules(schedules)
        @client = LineApiClient.new

        schedules.each do |type_schedules|
          next if type_schedules.blank?
          # roop with schedule types
          type_schedules.each do |schedule|
            post_schedule(schedule)
          end
        end
      end

      def post_schedule(schedule)
        talk_room_id = schedule.talk_room_id
        message = {
          type: 'text',
          text: schedule.title
        }
        @client.push_message(talk_room_id, message)
      end
    end
  end
end

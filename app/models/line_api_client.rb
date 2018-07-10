class LineApiClient
  include ActiveModel::Model
  attr_reader :client, :events
  attr_accessor :display_message

  def initialize
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
    @events = @client.parse_events_from(request.body.read)
  end

  def validate_signature
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do
        'Bad Request'
      end
    end
  end

  def create_schedule(event)
    schedule_info = get_schedule_info(event)
    case schedule_info[:post_data].start_with
    when /[一1]日だけ/
      create_specific_day_schedule(event, schedule_info)
    when /毎日/
      create_everyday_schedule(event, schedule_info)
    when /毎週/
      create_everyweek_schedule(event, schedule_info)
    when /毎月/
      create_everymonth_schedule(event, schedule_info)
    end
  end

  def create_complete_message(event); end

  def create_fail_message(event); end

  def create_reply_message(event)
    message = if !event.message['text'].nil? && event.message['text'][-2, 2] == '曜日'
                create_weekly_time_message(event)
              else
                create_response_message(event)
              end
  end

  private

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

  def create_everyday_schedule(event)
    post_time = Time.zone.parse(event['postback']['params']['time'])
    new_schedule = Schedule.new(
      title: schedule_info[:post_data].sub(/毎日/),
      talk_room_type_id: schedule_info[:talk_room_type_id],
      talk_room_id: schedule_info[:talk_room_id],
      schedule_type: Schedule.schedule_types[:everyday],
      post_hour: post_time.hour,
      post_minute: post_time.min,
      create_user_id: schedule_info[:create_user_id]
    )
    return true if new_schedule.save
  end

  def create_everyweek_schedule(event)
    post_day = event['postback']['data'][-3, 3]
    case post_day
    when '日曜日'
      post_wday = Schedule.post_wdays[:Sunday]
    when '月曜日'
      post_wday = Schedule.post_wdays[:Monday]
    when '火曜日'
      post_wday = Schedule.post_wdays[:Tuesday]
    when '水曜日'
      post_wday = Schedule.post_wdays[:Wednesday]
    when '木曜日'
      post_wday = Schedule.post_wdays[:Thursday]
    when '金曜日'
      post_wday = Schedule.post_wdays[:Friday]
    when '土曜日'
      post_wday = Schedule.post_wdays[:Saturday]
    end
    post_time = Time.zone.parse(event['postback']['params']['time'])
    new_schedule = Schedule.new(
      title: schedule_info[:post_data].delete("\n毎週").delete('その他').delete(post_day),
      talk_room_type_id: schedule_info[:talk_room_type_id],
      talk_room_id: schedule_info[:talk_room_id],
      schedule_type: Schedule.schedule_types[:everyweek],
      post_wday: post_wday,
      post_hour: post_time.hour,
      post_minute: post_time.min,
      create_user_id: schedule_info[:create_user_id]
    )
    return true if new_schedule.save
  end

  def create_everymonth_schedule(event)
    post_date = Time.zone.parse(event['postback']['params']['datetime'])
    new_schedule = Schedule.new(
      title: schedule_info[:post_data].sub(/毎月/),
      talk_room_type_id: schedule_info[:talk_room_type_id],
      talk_room_id: schedule_info[:talk_room_id],
      schedule_type: Schedule.schedule_types[:everymonth],
      post_day: post_date.day,
      post_hour: post_date.hour,
      post_minute: post_date.min,
      create_user_id: schedule_info[:create_user_id]
    )
    return true if new_schedule.save
  end
end

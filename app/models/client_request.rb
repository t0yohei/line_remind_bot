class ClientRequest
  include ActiveModel::Model
  attr_reader :body, :signature, :client, :events

  def initialize(request)
    @body = request.body.read
    @signature = request.env['HTTP_X_LINE_SIGNATURE']
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
    @events = @client.parse_events_from(@body)
  end

  def validate_signature
    unless client.validate_signature(body, signature)
      error 400 do
        'Bad Request'
      end
    end
  end

  def analyze
    case event
    when Line::Bot::Event::Postback
      create_schedule(event)
    when Line::Bot::Event::Message
      nil
    end
  end

  private

  def create_schedule(event)
    post_data = event['postback']['data']
    talk_room_type_id = TalkRoomType.find_by(type_name: event['source']['type']).id
    target_id_type = TalkRoomType.find_by(id: talk_room_type_id).target_id_type
    talk_room_id = event['source'][target_id_type]
    create_user_id = event['source']['userId']

    case post_data.start_with
    when /[一1]日だけ/
      post_date = Time.zone.parse(event['postback']['params']['datetime'])
      new_schedule = Schedule.new(
        title: post_data.sub(/[一1]日だけ/),
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: 0,
        post_year: post_date.year,
        post_month: post_date.mon,
        post_day: post_date.day,
        post_hour: post_date.hour,
        post_minute: post_date.min,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end

    when /毎日/
      post_time = Time.zone.parse(event['postback']['params']['time'])
      new_schedule = Schedule.new(
        title: post_data.sub(/毎日/),
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: 1,
        post_hour: post_time.hour,
        post_minute: post_time.min,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end
    when /毎週/
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
        title: post_data.delete("\n毎週").delete('その他').delete(post_day),
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: 2,
        post_wday: post_wday,
        post_hour: post_time.hour,
        post_minute: post_time.min,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end

    when /毎月/
      post_date = Time.zone.parse(event['postback']['params']['datetime'])
      new_schedule = Schedule.new(
        title: post_data..sub(/毎月/),
        talk_room_type_id: talk_room_type_id,
        talk_room_id: talk_room_id,
        schedule_type: 3,
        post_day: post_date.day,
        post_hour: post_date.hour,
        post_minute: post_date.min,
        create_user_id: create_user_id
      )
      if new_schedule.save
        return create_complete_message(event)
      else
        return 'エラーが発生しました'
      end

    end
  end
end

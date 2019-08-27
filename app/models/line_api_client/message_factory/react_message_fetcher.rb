class LineApiClient::MessageFactory::ReactMessageFetcher
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def build
    return fetch_default_delete_message
  end

  private

  def fetch_default_delete_message
    target_list = search_delete_target_list
    {
      type: 'text',
      text: delete_default_message(target_list)
    }
  end

  def search_delete_target_list
    talk_room_type_id = TalkRoomType.find_by(
      type_name: event['source']['type']
    ).id
    target_id_type = TalkRoomType.find_by(
      id: talk_room_type_id
    ).target_id_type
    talk_room_id = event['source'][target_id_type]
    Schedule.where(
      talk_room_type_id: talk_room_type_id,
      talk_room_id: talk_room_id,
      deleted: false
    ).where.not(
      schedule_type: Schedule.schedule_types[:specific_day], sent: true
    ).pluck(
      :id,
      :title
    )
  end

  def delete_default_message(target_list)
    <<~DELETE_DEFAULT_MESSAGE
      ■削除するスケジュールのIDを入力してください
      ■予定一覧：#{target_list.map { |id, title| id.to_s + '.' + title }.join', '}
      ----例----
      削除
      1
    DELETE_DEFAULT_MESSAGE
  end
end
class MessageFactory
  include ActiveModel::Model

  class << self
    def get_complete_message(event)
      case event['postback']['params'].first.first
      when /datetime/
        get_datetime_complete_message(event)
      when /time/
        get_time_complete_message(event)
      end
    end

    def get_fail_message(_event)
      {
        type: 'text',
        text: '予定の登録に失敗しました。'
      }
    end

    def get_delete_complete_message(event)
      schedule_id = event.message['text'].delete("\n削除")
      message = {
        type: 'text',
        text: "ID:#{schedule_id}を削除しました"
      }
      message
    end

    def get_delete_fail_message(event)
      schedule_id = event.message['text'].delete("\n削除")
      {
        type: 'text',
        text: "ID:#{schedule_id}の削除に失敗しました"
      }
    end

    def get_react_message(event)
      input_text = event.message['text']
      p 'input_text', input_text
      case input_text
      when /\A(> )?予定を登録/
        get_default_message
      when /\A一日だけ.*/
        get_specific_day_message(event)
      when /\A毎日.*/
        p '毎日'
        get_daily_message(event)
      when /\A毎週.*曜日/m
        p '毎週曜日'
        # 特定の曜日が選択された場合
        get_weekly_time_message(event)
      when /\A毎週.*その他.*/m
        p '毎週その他'
        # その他が選択された場合
        get_another_weekly_message(event)
      when /\A毎週.*/
        p '毎週'
        get_weekly_message(event)
      when /\A毎月.*/
        p '毎月'
        get_monthly_message(event)
      when /\A(> )?予定を削除/
        get_default_delete_message(event)
      else
        get_not_found_message
      end
    end

    private

    def get_datetime_complete_message(event)
      {
        type: 'text',
        text: event['postback']['params']['datetime'] + ' が入力されました'
      }
    end

    def get_time_complete_message(event)
      {
        type: 'text',
        text: event['postback']['params']['time'] + ' が入力されました'
      }
    end

    def get_default_message
      {
        type: 'text',
        text: default_text
      }
    end

    def default_text
      <<~DEFAULT_MESSAGE
        ■タイトルとカテゴリを入力してください
        ■カテゴリ：「一日だけ」・「毎日」・「毎週」・「毎月」
        ----例----
        毎日
        海水浴
        DEFAULT_MESSAGE
    end

    def get_default_delete_message(event)
      target_list = search_delete_target_list(event)
      {
        type: 'text',
        text: delete_default_message(target_list)
      }
    end

    def get_not_found_message
      {
        type: 'text',
        text: 'any response message was found'
      }
    end

    def search_delete_target_list(event)
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

    def get_specific_day_message(event)
      {
        type: 'template',
        altText: 'this is an template message',
        template: {
          type: 'buttons',
          title: '一日だけ',
          text: event.message['text'],
          actions: [
            {
              type: 'datetimepicker',
              label: '日時を指定',
              data: event.message['text'],
              mode: 'datetime'
            }
          ]
        }
      }
    end

    def get_daily_message(event)
      {
        type: 'template',
        altText: 'this is an template message',
        template: {
          type: 'buttons',
          title: '毎日',
          text: event.message['text'],
          actions: [
            {
              type: 'datetimepicker',
              label: '時間を指定',
              data: event.message['text'],
              mode: 'time'
            }
          ]
        }
      }
    end

    def get_weekly_message(event)
      {
        type: 'template',
        altText: 'this is an template message',
        template: {
          type: 'buttons',
          title: '曜日選択',
          text: event.message['text'],
          actions: [
            {
              type: 'message',
              label: '月曜日',
              text: event.message['text'] + '月曜日'
            },
            {
              type: 'message',
              label: '火曜日',
              text: event.message['text'] + '火曜日'
            },
            {
              type: 'message',
              label: '水曜日',
              text: event.message['text'] + '水曜日'
            },
            {
              type: 'message',
              label: 'その他の曜日',
              text: event.message['text'] + 'その他'
            }
          ]
        }
      }
    end

    def get_another_weekly_message(event)
      {
        type: 'template',
        altText: 'this is an template message',
        template: {
          type: 'buttons',
          title: '曜日選択',
          text: event.message['text'] + "\n曜日を選択してください",
          actions: [
            {
              type: 'message',
              label: '木曜日',
              text: event.message['text'] + '木曜日'
            },
            {
              type: 'message',
              label: '金曜日',
              text: event.message['text'] + '金曜日'
            },
            {
              type: 'message',
              label: '土曜日',
              text: event.message['text'] + '土曜日'
            },
            {
              type: 'message',
              label: '日曜日',
              text: event.message['text'] + '日曜日'
            }
          ]
        }
      }
    end

    def get_weekly_time_message(event)
      {
        type: 'template',
        altText: 'this is an template message',
        template: {
          type: 'buttons',
          title: '時間を選択',
          text: event.message['text'],
          actions: [
            {
              type: 'datetimepicker',
              label: '日時を指定',
              data: event.message['text'],
              mode: 'time'
            }
          ]
        }
      }
    end

    def get_monthly_message(event)
      {
        type: 'template',
        altText: 'this is an template message',
        template: {
          type: 'buttons',
          title: '毎月',
          text: event.message['text'],
          actions: [
            {
              type: 'datetimepicker',
              label: '日時を指定',
              data: event.message['text'],
              mode: 'datetime'
            }
          ]
        }
      }
    end
  end
end

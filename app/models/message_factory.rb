class MessageFactory
  include ActiveModel::Model

  class << self
    def generate_complete_message(event)
      case event['postback']['params'].first.first
      when /datetime/
        generate_datetime_complete_message(event)
      when /time/
        generate_time_complete_message(event)
      end
    end

    def generate_fail_message(_event)
      {
        type: 'text',
        text: '予定の登録に失敗しました。'
      }
    end

    def generate_delete_complete_message(event)
      schedule_id = event.message['text'].delete("\n削除")
      message = {
        type: 'text',
        text: "ID:#{schedule_id}を削除しました"
      }
      message
    end

    def generate_delete_fail_message(event)
      schedule_id = event.message['text'].delete("\n削除")
      {
        type: 'text',
        text: "ID:#{schedule_id}の削除に失敗しました"
      }
    end

    def generate_react_message(event)
      input_text = event.message['text']
      case input_text
      when /\A(> )?予定を登録/
        default_message
      when /\A一日だけ*/
        generate_specific_day_message(event)
      when /\A毎日*/
        generate_daily_message(event)
      when /\A毎週その他.曜日*/
        # 特定の曜日が選択された場合
        generate_weekly_time_message(event)
      when /\A毎週その他*/
        # その他が選択された場合
        generate_another_weekly_message(event)
      when /\A毎週*/
        generate_weekly_message(event)
      when /\A毎月*/
        generate_monthly_message(event)
      when /\A(> )?予定を削除/
        generate_default_delete_message(event)
      end
    end

    private

    def generate_datetime_complete_message(event)
      {
        type: 'text',
        text: event['postback']['params']['datetime'] + ' が入力されました'
      }
    end

    def generate_time_complete_message(event)
      {
        type: 'text',
        text: event['postback']['params']['time'] + ' が入力されました'
      }
    end

    def default_message
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

    def generate_default_delete_message(event)
      target_list = search_delete_target_list(event)
      {
        type: 'text',
        text: delete_default_message(target_list)
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

    def generate_specific_day_message(event)
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

    def generate_daily_message(event)
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

    def generate_weekly_message(event)
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

    def generate_another_weekly_message(event)
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

    def generate_weekly_time_message(event)
      {
        type: 'template',
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

    def generate_monthly_message(event)
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

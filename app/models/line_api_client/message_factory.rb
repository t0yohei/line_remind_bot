class LineApiClient::MessageFactory
  include ActiveModel::Model

  class << self
    def get_react_message(event)
      LineApiClient::MessageFactory::ReactMessageBuilder.new(
        event
      ).build
    end

    def get_complete_message(event)
      postback_params = event['postback']['params']
      LineApiClient::MessageFactory::CompleteMessageBuilder.new(
        postback_params
      ).build
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
  end
end
class LineApiClient::MessageFactory::ReactMessageGetter
  attr_reader :input_text

  def initialize(input_text)
    @input_text = input_text
  end

  def build
    case input_text
    when /\A(> )?予定を登録/
      get_default_message
    when /\A一日だけ.*/
      get_specific_day_message
    when /\A毎日.*/
      p '毎日'
      get_daily_message
    when /\A毎週.*曜日/m
      p '毎週曜日'
      # 特定の曜日が選択された場合
      get_weekly_time_message
    when /\A毎週.*その他.*/m
      p '毎週その他'
      # その他が選択された場合
      get_another_weekly_message
    when /\A毎週.*/
      p '毎週'
      get_weekly_message
    when /\A毎月.*/
      p '毎月'
      get_monthly_message
    else
      get_not_found_message
    end
  end

  private

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

  def get_not_found_message
    {
      type: 'text',
      text: '入力値を確認してください'
    }
  end

  def get_specific_day_message
    {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '一日だけ',
        text: input_text,
        actions: [
          {
            type: 'datetimepicker',
            label: '日時を指定',
            data: input_text,
            mode: 'datetime'
          }
        ]
      }
    }
  end

  def get_daily_message
    {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '毎日',
        text: input_text,
        actions: [
          {
            type: 'datetimepicker',
            label: '時間を指定',
            data: input_text,
            mode: 'time'
          }
        ]
      }
    }
  end

  def get_weekly_message
    {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '曜日選択',
        text: input_text,
        actions: [
          {
            type: 'message',
            label: '月曜日',
            text: input_text + '月曜日'
          },
          {
            type: 'message',
            label: '火曜日',
            text: input_text + '火曜日'
          },
          {
            type: 'message',
            label: '水曜日',
            text: input_text + '水曜日'
          },
          {
            type: 'message',
            label: 'その他の曜日',
            text: input_text + 'その他'
          }
        ]
      }
    }
  end

  def get_another_weekly_message
    {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '曜日選択',
        text: input_text + "\n曜日を選択してください",
        actions: [
          {
            type: 'message',
            label: '木曜日',
            text: input_text + '木曜日'
          },
          {
            type: 'message',
            label: '金曜日',
            text: input_text + '金曜日'
          },
          {
            type: 'message',
            label: '土曜日',
            text: input_text + '土曜日'
          },
          {
            type: 'message',
            label: '日曜日',
            text: input_text + '日曜日'
          }
        ]
      }
    }
  end

  def get_weekly_time_message
    {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '時間を選択',
        text: input_text,
        actions: [
          {
            type: 'datetimepicker',
            label: '日時を指定',
            data: input_text,
            mode: 'time'
          }
        ]
      }
    }
  end

  def get_monthly_message
    {
      type: 'template',
      altText: 'this is an template message',
      template: {
        type: 'buttons',
        title: '毎月',
        text: input_text,
        actions: [
          {
            type: 'datetimepicker',
            label: '日時を指定',
            data: input_text,
            mode: 'datetime'
          }
        ]
      }
    }
  end
end
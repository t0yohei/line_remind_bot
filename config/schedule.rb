# ログの出力先を設定
set :output, 'log/crontab.log'
# development 環境で cron 実行
set :environment, :development

# 1分毎に回す
every 1.minute do
  runner 'Tasks::RegularMessage.remind_schedules'
end

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

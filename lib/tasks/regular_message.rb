class RegularMessage
  def remind_schedules
    schedules = select_schedules(Date.today)
    post_schedules(schedules)
  end

  def select_schedules(date)
    schedules =[]
    schedules = select_specific_day_schdules(date, schedules)
    schedules = select_daily_schdules(date, schedules)
    schedules = select_weekly_schdules(date, schedules)
    schedules = select_monthly_schdules(date, schedules)
    return schedules

  end

  def select_specific_day_schdules(date, schedules)
  end

  def select_daily_schdules(date, schedules)
  end

  def select_weekly_schdules(date, schedules)
  end

  def select_monthly_schdules(date, schedules)
  end

  def post_schedules
  end

end

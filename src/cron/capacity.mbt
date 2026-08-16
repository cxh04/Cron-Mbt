///|
/// A bounded capacity view for operational dashboards and admission control.
pub(all) struct CapacityPolicy {
  max_events_per_day : Int
  max_events_per_window : Int
}

///|
pub fn CapacityPolicy::new(
  max_events_per_day : Int,
  max_events_per_window : Int,
) -> Result[CapacityPolicy, CronError] {
  if max_events_per_day <= 0 || max_events_per_window <= 0 {
    return Err(OutOfBounds("capacity limits must be positive"))
  }
  Ok({ max_events_per_day, max_events_per_window })
}

///|
pub fn CronExpr::daily_capacity(self : CronExpr) -> Array[Int] {
  let result = Array::make(24, 0)
  if self.day_of_month_wildcard && self.day_of_week_wildcard {
    for hour in self.hours {
      result[hour] = self.minutes.length()
    }
  } else if self.day_of_week_wildcard {
    for hour in self.hours {
      result[hour] = self.minutes.length()
    }
  } else {
    for hour in self.hours {
      result[hour] = self.minutes.length()
    }
  }
  result
}

///|
pub fn CronExpr::weekly_capacity_profile(self : CronExpr) -> Array[Int] {
  let result = Array::make(7, 0)
  for weekday in self.days_of_week {
    if self.day_of_month_wildcard {
      result[weekday] = self.time_slots_per_day()
    } else if self.day_of_week_wildcard {
      result[weekday] = self.time_slots_per_day()
    } else {
      result[weekday] = self.time_slots_per_day()
    }
  }
  result
}

///|
pub fn CronExpr::monthly_capacity(
  self : CronExpr,
  year : Int,
  month : Int,
) -> Result[Int, CronError] {
  let report = match
    self.month_report(year, month, BusinessCalendar::standard([])) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok(report.occurrences)
}

///|
pub fn CronExpr::exceeds_capacity(
  self : CronExpr,
  policy : CapacityPolicy,
) -> Bool {
  self.events_per_day() > policy.max_events_per_day ||
  self.time_slots_per_day() > policy.max_events_per_window
}

///|
pub fn CronExpr::capacity_report(self : CronExpr) -> String {
  let profile = self.daily_capacity()
  let mut total = 0
  let mut peak = 0
  for value in profile {
    total += value
    if value > peak {
      peak = value
    }
  }
  "daily-total=\{total}; peak-hourly=\{peak}; weekdays=\{self.days_of_week.length()}; months=\{self.months.length()}"
}

///|
pub fn CronExpr::capacity_for_date(
  self : CronExpr,
  year : Int,
  month : Int,
  day : Int,
) -> Result[Int, CronError] {
  self
  .matching_minutes_on_date(year, month, day)
  .map(fn(values) { values.length() })
}

///|
pub fn CronExpr::business_capacity_for_month(
  self : CronExpr,
  year : Int,
  month : Int,
  calendar : BusinessCalendar,
) -> Result[Int, CronError] {
  let days = match calendar.working_dates_in_month(year, month) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  let mut total = 0
  for day in days {
    total += self.capacity_for_date(year, month, day).unwrap()
  }
  Ok(total)
}

///|
pub fn CronExpr::capacity_buckets(self : CronExpr) -> Array[(Int, Int)] {
  let result : Array[(Int, Int)] = []
  for index, value in self.daily_capacity() {
    result.push((index, value))
  }
  result
}

///|
pub fn CapacityPolicy::describe(self : CapacityPolicy) -> String {
  "daily-limit=\{self.max_events_per_day}; window-limit=\{self.max_events_per_window}"
}

///|
pub(all) struct CronStats {
  minute_slots : Int
  hour_slots : Int
  month_slots : Int
  weekday_slots : Int
  day_of_month_slots : Int
  events_per_day : Int
  minimum_gap : Int
  maximum_gap : Int
}

///|
pub fn CronExpr::stats(
  self : CronExpr,
  sample_start : DateTime,
) -> Result[CronStats, CronError] {
  let minimum_gap = match self.minimum_gap_minutes(sample_start, 3) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  let maximum_gap = match self.maximum_gap_minutes(sample_start, 3) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok({
    minute_slots: self.minutes.length(),
    hour_slots: self.hours.length(),
    month_slots: self.months.length(),
    weekday_slots: self.days_of_week.length(),
    day_of_month_slots: self.days_of_month.length(),
    events_per_day: self.events_per_day(),
    minimum_gap,
    maximum_gap,
  })
}

///|
pub fn CronStats::render(self : CronStats) -> String {
  "minutes=\{self.minute_slots}; hours=\{self.hour_slots}; months=\{self.month_slots}; weekdays=\{self.weekday_slots}; days=\{self.day_of_month_slots}; daily=\{self.events_per_day}; gap=\{self.minimum_gap}-\{self.maximum_gap}m"
}

///|
pub fn CronExpr::matches_date(
  self : CronExpr,
  year : Int,
  month : Int,
  day : Int,
) -> Bool {
  contains(self.months, month) && self.matches_day(year, month, day)
}

///|
pub fn CronExpr::is_deterministic(self : CronExpr) -> Bool {
  self.minutes.length() == 1 &&
  self.hours.length() == 1 &&
  (
    (!self.day_of_month_wildcard && self.days_of_month.length() == 1) ||
    (!self.day_of_week_wildcard && self.days_of_week.length() == 1)
  )
}

///|
pub fn DateTime::date_key(self : DateTime) -> String {
  let month = if self.month < 10 {
    "0" + self.month.to_string()
  } else {
    self.month.to_string()
  }
  let day = if self.day < 10 {
    "0" + self.day.to_string()
  } else {
    self.day.to_string()
  }
  "\{self.year}-\{month}-\{day}"
}

///|
pub fn DateTime::to_iso8601(self : DateTime) -> String {
  let month = if self.month < 10 {
    "0" + self.month.to_string()
  } else {
    self.month.to_string()
  }
  let day = if self.day < 10 {
    "0" + self.day.to_string()
  } else {
    self.day.to_string()
  }
  let hour = if self.hour < 10 {
    "0" + self.hour.to_string()
  } else {
    self.hour.to_string()
  }
  let minute = if self.minute < 10 {
    "0" + self.minute.to_string()
  } else {
    self.minute.to_string()
  }
  "\{self.year}-\{month}-\{day}T\{hour}:\{minute}:00"
}

///|
pub fn DateTime::with_time(
  self : DateTime,
  hour : Int,
  minute : Int,
) -> Result[DateTime, CronError] {
  let result = { ..self, hour, minute }
  match result.validate() {
    Ok(_) => Ok(result)
    Err(err) => Err(err)
  }
}

///|
pub fn CronExpr::calendar_months(self : CronExpr) -> Array[Int] {
  self.months.copy()
}

///|
pub fn CronExpr::calendar_weekdays(self : CronExpr) -> Array[Int] {
  self.days_of_week.copy()
}

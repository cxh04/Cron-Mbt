///|
pub fn CronExpr::next_or_same(
  self : CronExpr,
  current : DateTime,
) -> Result[DateTime, CronError] {
  if self.matches_datetime(current) {
    Ok(current)
  } else {
    self.next_time(current)
  }
}

///|
pub fn CronExpr::previous_time(
  self : CronExpr,
  current : DateTime,
) -> Result[DateTime, CronError] {
  match current.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let cursor = { ..current }
  cursor.minute -= 1
  let mut attempts = 0
  while attempts < 200000 {
    if cursor.minute < 0 {
      cursor.minute = 59
      cursor.hour -= 1
    }
    if cursor.hour < 0 {
      cursor.hour = 23
      cursor.day -= 1
    }
    if cursor.day < 1 {
      cursor.month -= 1
      if cursor.month < 1 {
        cursor.month = 12
        cursor.year -= 1
      }
      cursor.day = days_in_month(cursor.year, cursor.month)
    }
    if self.matches_datetime(cursor) {
      return Ok(cursor)
    }
    cursor.minute -= 1
    attempts += 1
  }
  Err(InvalidFormat("previous occurrence search exceeded safety limit"))
}

///|
pub fn CronExpr::previous_times(
  self : CronExpr,
  current : DateTime,
  count : Int,
) -> Result[Array[DateTime], CronError] {
  if count < 0 {
    return Err(InvalidFormat("count cannot be negative"))
  }
  let result = []
  let mut cursor = current
  for _ in 0..<count {
    let previous = match self.previous_time(cursor) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    result.push(previous)
    cursor = previous
  }
  Ok(result)
}

///|
pub fn CronExpr::is_hourly(self : CronExpr) -> Bool {
  self.minutes.length() == 1 &&
  self.hours.length() == 24 &&
  self.day_of_month_wildcard &&
  self.day_of_week_wildcard &&
  self.months.length() == 12
}

///|
pub fn CronExpr::is_daily(self : CronExpr) -> Bool {
  self.minutes.length() == 1 &&
  self.hours.length() == 1 &&
  self.day_of_month_wildcard &&
  self.day_of_week_wildcard &&
  self.months.length() == 12
}

///|
pub fn CronExpr::is_weekly(self : CronExpr) -> Bool {
  self.minutes.length() == 1 &&
  self.hours.length() == 1 &&
  self.day_of_month_wildcard &&
  self.days_of_week.length() == 1 &&
  self.months.length() == 12
}

///|
pub fn CronExpr::events_per_day(self : CronExpr) -> Int {
  self.minutes.length() * self.hours.length()
}

///|
pub fn CronExpr::events_per_week(self : CronExpr) -> Int {
  if self.day_of_month_wildcard && self.day_of_week_wildcard {
    self.events_per_day() * 7
  } else if self.day_of_month_wildcard {
    self.events_per_day() * self.days_of_week.length()
  } else {
    self.events_per_day() * 7
  }
}

///|
pub fn CronExpr::events_per_month(
  self : CronExpr,
  year : Int,
  month : Int,
) -> Int {
  let mut total = 0
  let dim = days_in_month(year, month)
  for day in 1..<=dim {
    if self.matches(year, 0, 0, day, month, day_of_week(year, month, day)) {
      total += self.events_per_day()
    }
  }
  total
}

///|
pub fn CronExpr::matches_window(
  self : CronExpr,
  start : DateTime,
  end : DateTime,
) -> Result[Array[Bool], CronError] {
  if !start.is_before(end) {
    return Err(InvalidFormat("end must be after start"))
  }
  let length = match start.minutes_until(end) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  let result = []
  let mut current = start
  for _ in 0..<length {
    result.push(self.matches_datetime(current))
    current = current.add_minutes(1).unwrap()
  }
  Ok(result)
}

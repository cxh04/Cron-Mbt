///|
pub(all) struct BusinessCalendar {
  holidays : Array[DateTime]
  weekend_days : Array[Int]
}

///|
pub fn BusinessCalendar::standard(
  holidays : Array[DateTime],
) -> BusinessCalendar {
  { holidays, weekend_days: [0, 6] }
}

///|
pub fn BusinessCalendar::with_weekend_days(
  holidays : Array[DateTime],
  weekend_days : Array[Int],
) -> BusinessCalendar {
  { holidays, weekend_days }
}

///|
pub fn BusinessCalendar::is_holiday(
  self : BusinessCalendar,
  dt : DateTime,
) -> Bool {
  for holiday in self.holidays {
    if holiday.year == dt.year &&
      holiday.month == dt.month &&
      holiday.day == dt.day {
      return true
    }
  }
  false
}

///|
pub fn BusinessCalendar::is_working_day(
  self : BusinessCalendar,
  dt : DateTime,
) -> Bool {
  !self.weekend_days.contains(dt.weekday()) && !self.is_holiday(dt)
}

///|
pub fn BusinessCalendar::working_days_between(
  self : BusinessCalendar,
  start : DateTime,
  end : DateTime,
) -> Result[Int, CronError] {
  if !start.is_before(end) {
    return Err(InvalidFormat("end must be after start"))
  }
  let cursor = start.start_of_day()
  let end_day = end.start_of_day()
  let mut count = 0
  let mut current = cursor
  let mut attempts = 0
  while current.is_before(end_day) && attempts < 100000 {
    if self.is_working_day(current) {
      count += 1
    }
    current = current.add_minutes(1440).unwrap()
    attempts += 1
  }
  if attempts >= 100000 {
    return Err(InvalidFormat("business-day range exceeded safety limit"))
  }
  Ok(count)
}

///|
pub fn BusinessCalendar::next_working_day(
  self : BusinessCalendar,
  current : DateTime,
) -> Result[DateTime, CronError] {
  let mut result = current.start_of_day()
  for _ in 0..<370 {
    result = result.add_minutes(1440).unwrap()
    if self.is_working_day(result) {
      return Ok(result)
    }
  }
  Err(InvalidFormat("no working day found in one-year search window"))
}

///|
pub fn CronExpr::next_business_times(
  self : CronExpr,
  current : DateTime,
  calendar : BusinessCalendar,
  count : Int,
) -> Result[Array[DateTime], CronError] {
  if count < 0 {
    return Err(InvalidFormat("count cannot be negative"))
  }
  let result = []
  let mut cursor = current
  let mut attempts = 0
  while result.length() < count && attempts < 200000 {
    let next = match self.next_time(cursor) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    if calendar.is_working_day(next) {
      result.push(next)
    }
    cursor = next
    attempts += 1
  }
  if result.length() < count {
    return Err(
      InvalidFormat("business occurrence search exceeded safety limit"),
    )
  }
  Ok(result)
}

///|
pub fn CronExpr::business_occurrences_between(
  self : CronExpr,
  start : DateTime,
  end : DateTime,
  limit : Int,
  calendar : BusinessCalendar,
) -> Result[Array[DateTime], CronError] {
  let all = match self.occurrences_between(start, end, limit * 4 + 1) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  let result = []
  for value in all {
    if calendar.is_working_day(value) && result.length() < limit {
      result.push(value)
    }
  }
  Ok(result)
}

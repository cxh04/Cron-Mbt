///|
/// A compact, deterministic view of a schedule over a bounded window.
pub(all) struct ScheduleObservation {
  start : DateTime
  end : DateTime
  occurrence_count : Int
  first : DateTime?
  last : DateTime?
  average_gap_minutes : Int
  business_occurrence_count : Int
}

///|
pub fn CronExpr::observe_window(
  self : CronExpr,
  range : DateTimeRange,
  limit : Int,
  calendar : BusinessCalendar,
) -> Result[ScheduleObservation, CronError] {
  if limit <= 0 {
    return Err(OutOfBounds("observation limit must be positive"))
  }
  let values = match self.occurrences_in_range(range, limit) {
    Ok(items) => items
    Err(err) => return Err(err)
  }
  let business = self.business_occurrences_in_range(range, limit, calendar)
  let business_count = match business {
    Ok(items) => items.length()
    Err(err) => return Err(err)
  }
  let first = if values.is_empty() { None } else { Some(values[0]) }
  let last = if values.is_empty() {
    None
  } else {
    Some(values[values.length() - 1])
  }
  let average_gap_minutes = if values.length() < 2 {
    0
  } else {
    values[0].minutes_until(values[values.length() - 1]).unwrap() /
    (values.length() - 1)
  }
  Ok({
    start: range.start,
    end: range.end,
    occurrence_count: values.length(),
    first,
    last,
    average_gap_minutes,
    business_occurrence_count: business_count,
  })
}

///|
pub fn ScheduleObservation::render(self : ScheduleObservation) -> String {
  let first = match self.first {
    Some(value) => value.to_iso8601()
    None => "none"
  }
  let last = match self.last {
    Some(value) => value.to_iso8601()
    None => "none"
  }
  "window=\{self.start.date_key()}..\{self.end.date_key()}; occurrences=\{self.occurrence_count}; business=\{self.business_occurrence_count}; first=\{first}; last=\{last}; average-gap=\{self.average_gap_minutes}m"
}

///|
/// Return all matching day numbers in a valid month, in ascending order.
pub fn CronExpr::matching_dates_in_month(
  self : CronExpr,
  year : Int,
  month : Int,
) -> Result[Array[Int], CronError] {
  if month < 1 || month > 12 || year < 1 {
    return Err(OutOfBounds("invalid month"))
  }
  let result : Array[Int] = []
  for day = 1; day <= days_in_month(year, month); day = day + 1 {
    if self.matches_date(year, month, day) {
      result.push(day)
    }
  }
  Ok(result)
}

///|
/// Return a day-indexed occurrence histogram for one calendar month.
pub fn CronExpr::monthly_histogram(
  self : CronExpr,
  year : Int,
  month : Int,
) -> Result[Array[Int], CronError] {
  let days = match self.matching_dates_in_month(year, month) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  let result : Array[Int] = []
  for index = 0; index < days_in_month(year, month); index = index + 1 {
    result.push(0)
  }
  for day in days {
    result[day - 1] = self.minutes.length() * self.hours.length()
  }
  let mut any = false
  for value in result {
    if value != 0 {
      any = true
    }
  }
  if any {
    Ok(result)
  } else {
    Ok([])
  }
}

///|
/// Approximate maximum number of events in a complete seven-day period.
pub fn CronExpr::weekly_capacity(self : CronExpr) -> Int {
  if self.day_of_month_wildcard && !self.day_of_week_wildcard {
    self.minutes.length() * self.hours.length() * self.days_of_week.length()
  } else if !self.day_of_month_wildcard && self.day_of_week_wildcard {
    self.minutes.length() *
    self.hours.length() *
    self.days_of_month.length() /
    4
  } else if self.day_of_month_wildcard && self.day_of_week_wildcard {
    self.minutes.length() * self.hours.length() * 7
  } else {
    self.minutes.length() * self.hours.length() * 7
  }
}

///|
/// Return valid working dates in a month for calendar administration.
pub fn BusinessCalendar::working_dates_in_month(
  self : BusinessCalendar,
  year : Int,
  month : Int,
) -> Result[Array[Int], CronError] {
  if year < 1 || month < 1 || month > 12 {
    return Err(OutOfBounds("invalid month"))
  }
  let result : Array[Int] = []
  for day = 1; day <= days_in_month(year, month); day = day + 1 {
    let dt : DateTime = { year, month, day, hour: 0, minute: 0 }
    if self.is_working_day(dt) {
      result.push(day)
    }
  }
  Ok(result)
}

///|
pub fn BusinessCalendar::add_holiday(
  self : BusinessCalendar,
  year : Int,
  month : Int,
  day : Int,
) -> BusinessCalendar {
  let result = { ..self }
  let holiday : DateTime = { year, month, day, hour: 0, minute: 0 }
  if !result.holidays.contains(holiday) {
    result.holidays.push(holiday)
  }
  result
}

///|
pub fn BusinessCalendar::holiday_count(self : BusinessCalendar) -> Int {
  self.holidays.length()
}

///|
pub fn BusinessCalendar::describe(self : BusinessCalendar) -> String {
  "weekend-days=\{self.weekend_days.length()}; holidays=\{self.holidays.length()}"
}

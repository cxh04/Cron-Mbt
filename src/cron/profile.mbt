///|
pub fn CronExpr::count_occurrences_between(
  self : CronExpr,
  start : DateTime,
  end : DateTime,
  limit : Int,
) -> Result[Int, CronError] {
  let values = match self.occurrences_between(start, end, limit) {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  Ok(values.length())
}

///|
pub fn CronExpr::hourly_profile(
  self : CronExpr,
  year : Int,
  month : Int,
  day : Int,
) -> Array[Int] {
  let result = Array::make(24, 0)
  for hour in 0..<=23 {
    for minute in 0..<=59 {
      if self.matches(
          year,
          minute,
          hour,
          day,
          month,
          day_of_week(year, month, day),
        ) {
        result[hour] += 1
      }
    }
  }
  result
}

///|
pub fn CronExpr::weekday_profile(self : CronExpr) -> Array[Int] {
  let result = Array::make(7, 0)
  for weekday in 0..<=6 {
    if contains(self.days_of_week, weekday) {
      result[weekday] = self.events_per_day()
    }
  }
  result
}

///|
pub fn CronExpr::next_n_from(
  self : CronExpr,
  current : DateTime,
  count : Int,
) -> Result[Array[String], CronError] {
  let values = match self.next_times(current, count) {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  Ok(values.map(fn(value) { value.format() }))
}

///|
pub fn CronExpr::previous_n_from(
  self : CronExpr,
  current : DateTime,
  count : Int,
) -> Result[Array[String], CronError] {
  let values = match self.previous_times(current, count) {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  Ok(values.map(fn(value) { value.format() }))
}

///|
pub fn CronExpr::is_never_matching_on(
  self : CronExpr,
  year : Int,
  month : Int,
) -> Bool {
  self.events_per_month(year, month) == 0
}

///|
pub fn CronExpr::minimum_gap_minutes(
  self : CronExpr,
  start : DateTime,
  samples : Int,
) -> Result[Int, CronError] {
  if samples < 2 {
    return Err(InvalidFormat("at least two samples are required"))
  }
  let values = match self.next_times(start, samples) {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  let mut minimum = 2000000000
  for i in 1..<values.length() {
    let gap = match values[i - 1].minutes_until(values[i]) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    if gap < minimum {
      minimum = gap
    }
  }
  Ok(minimum)
}

///|
pub fn CronExpr::maximum_gap_minutes(
  self : CronExpr,
  start : DateTime,
  samples : Int,
) -> Result[Int, CronError] {
  if samples < 2 {
    return Err(InvalidFormat("at least two samples are required"))
  }
  let values = match self.next_times(start, samples) {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  let mut maximum = 0
  for i in 1..<values.length() {
    let gap = match values[i - 1].minutes_until(values[i]) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    if gap > maximum {
      maximum = gap
    }
  }
  Ok(maximum)
}

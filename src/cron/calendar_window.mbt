///|
/// Return all matching minute offsets on a validated calendar date.
pub fn CronExpr::matching_minutes_on_date(
  self : CronExpr,
  year : Int,
  month : Int,
  day : Int,
) -> Result[Array[Int], CronError] {
  let date : DateTime = { year, month, day, hour: 0, minute: 0 }
  match date.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  if !self.matches_date(year, month, day) {
    return Ok([])
  }
  let result : Array[Int] = []
  for hour in self.hours {
    for minute in self.minutes {
      result.push(hour * 60 + minute)
    }
  }
  result.sort()
  Ok(result)
}

///|
/// Return the matching hours for a validated calendar date.
pub fn CronExpr::matching_hours_on_date(
  self : CronExpr,
  year : Int,
  month : Int,
  day : Int,
) -> Result[Array[Int], CronError] {
  let minutes = match self.matching_minutes_on_date(year, month, day) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  let result : Array[Int] = []
  for minute in minutes {
    let hour = minute / 60
    if !result.contains(hour) {
      result.push(hour)
    }
  }
  Ok(result)
}

///|
/// Round down to a minute bucket inside an hour.
pub fn DateTime::floor_minutes(
  self : DateTime,
  bucket : Int,
) -> Result[DateTime, CronError] {
  if bucket <= 0 || bucket > 60 {
    return Err(OutOfBounds("minute bucket must be between 1 and 60"))
  }
  match self.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  Ok({ ..self, minute: self.minute / bucket * bucket })
}

///|
/// Round up to a minute bucket, carrying into the next hour when needed.
pub fn DateTime::ceil_minutes(
  self : DateTime,
  bucket : Int,
) -> Result[DateTime, CronError] {
  if bucket <= 0 || bucket > 60 {
    return Err(OutOfBounds("minute bucket must be between 1 and 60"))
  }
  match self.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let floor = self.minute / bucket * bucket
  let rounded = if floor == self.minute {
    self
  } else {
    self.add_minutes(bucket - (self.minute - floor)).unwrap()
  }
  Ok(rounded)
}

///|
/// Check that the date fields, independent of time, form a real calendar day.
pub fn DateTime::is_valid_calendar_day(self : DateTime) -> Bool {
  self.year >= 1 &&
  self.year <= 9999 &&
  self.month >= 1 &&
  self.month <= 12 &&
  self.day >= 1 &&
  self.day <= days_in_month(self.year, self.month)
}

///|
/// Return the number of days in this datetime's year.
pub fn DateTime::days_in_current_year(self : DateTime) -> Int {
  if is_leap_year(self.year) {
    366
  } else {
    365
  }
}

///|
fn days_before_year(year : Int) -> Int {
  let mut total = 0
  for y = 1; y < year; y = y + 1 {
    total += if is_leap_year(y) { 366 } else { 365 }
  }
  total
}

///|
fn days_before_month(year : Int, month : Int) -> Int {
  let mut total = 0
  for m = 1; m < month; m = m + 1 {
    total += days_in_month(year, m)
  }
  total
}

///|
pub fn DateTime::weekday(self : DateTime) -> Int {
  day_of_week(self.year, self.month, self.day)
}

///|
pub fn DateTime::weekday_name(self : DateTime) -> String {
  match self.weekday() {
    0 => "Sunday"
    1 => "Monday"
    2 => "Tuesday"
    3 => "Wednesday"
    4 => "Thursday"
    5 => "Friday"
    _ => "Saturday"
  }
}

///|
pub fn DateTime::is_weekend(self : DateTime) -> Bool {
  let weekday = self.weekday()
  weekday == 0 || weekday == 6
}

///|
pub fn DateTime::day_of_year(self : DateTime) -> Int {
  days_before_month(self.year, self.month) + self.day
}

///|
pub fn DateTime::start_of_day(self : DateTime) -> DateTime {
  { ..self, hour: 0, minute: 0 }
}

///|
pub fn DateTime::end_of_day(self : DateTime) -> DateTime {
  { ..self, hour: 23, minute: 59 }
}

///|
pub fn DateTime::minutes_until(
  self : DateTime,
  other : DateTime,
) -> Result[Int, CronError] {
  match self.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  match other.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  if other.is_before(self) {
    return Err(InvalidFormat("other datetime is before self"))
  }
  let self_days = days_before_year(self.year) +
    days_before_month(self.year, self.month) +
    self.day
  let other_days = days_before_year(other.year) +
    days_before_month(other.year, other.month) +
    other.day
  Ok(
    (other_days - self_days) * 1440 +
    (other.hour * 60 + other.minute) -
    (self.hour * 60 + self.minute),
  )
}

///|
pub fn days_between(start : DateTime, end : DateTime) -> Result[Int, CronError] {
  match start.minutes_until(end) {
    Ok(minutes) => Ok(minutes / 1440)
    Err(err) => Err(err)
  }
}

///|
pub fn month_name(month : Int) -> String {
  match month {
    1 => "January"
    2 => "February"
    3 => "March"
    4 => "April"
    5 => "May"
    6 => "June"
    7 => "July"
    8 => "August"
    9 => "September"
    10 => "October"
    11 => "November"
    12 => "December"
    _ => "Unknown"
  }
}

///|
pub fn quarter_of_month(month : Int) -> Int {
  if month <= 3 {
    1
  } else if month <= 6 {
    2
  } else if month <= 9 {
    3
  } else {
    4
  }
}

///|
pub fn is_business_day(year : Int, month : Int, day : Int) -> Bool {
  let weekday = day_of_week(year, month, day)
  weekday != 0 && weekday != 6
}

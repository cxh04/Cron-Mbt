///|
/// Stable `HH:MM` value for logs and CSV exports.
pub fn DateTime::time_key(self : DateTime) -> String {
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
  "\{hour}:\{minute}"
}

///|
/// Compare only the calendar portion of two valid datetimes.
pub fn DateTime::same_date(self : DateTime, other : DateTime) -> Bool {
  self.year == other.year && self.month == other.month && self.day == other.day
}

///|
/// Minutes elapsed since the beginning of the day.
pub fn DateTime::minutes_since_midnight(self : DateTime) -> Int {
  self.hour * 60 + self.minute
}

///|
/// Number of minute slots produced on one matching calendar day.
pub fn CronExpr::time_slots_per_day(self : CronExpr) -> Int {
  self.minutes.length() * self.hours.length()
}

///|
/// Compact line suitable for CLI status output.
pub fn CronExpr::summary_line(self : CronExpr) -> String {
  "\{self.canonical()} | \{self.describe()} | slots=\{self.time_slots_per_day()}"
}

///|
/// Match at least one datetime from a candidate collection.
pub fn CronExpr::matches_any(self : CronExpr, values : Array[DateTime]) -> Bool {
  for value in values {
    if self.matches_datetime(value) {
      return true
    }
  }
  false
}

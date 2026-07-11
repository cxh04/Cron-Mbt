///|
pub(all) struct DateTime {
  mut year : Int
  mut month : Int
  mut day : Int
  mut hour : Int
  mut minute : Int
} derive(Debug, Eq)

///|
fn CronExpr::matches_day(
  self : CronExpr,
  year : Int,
  month : Int,
  day : Int,
) -> Bool {
  let dim = days_in_month(year, month)
  let matches_dom = contains(self.days_of_month, day) ||
    (self.has_last_day_of_month && day == dim)
  let matches_dow = contains(self.days_of_week, day_of_week(year, month, day))
  if self.day_of_month_wildcard && self.day_of_week_wildcard {
    true
  } else if self.day_of_month_wildcard {
    matches_dow
  } else if self.day_of_week_wildcard {
    matches_dom
  } else {
    matches_dom || matches_dow
  }
}

///|
fn CronExpr::set_first_valid_time(self : CronExpr, dt : DateTime) -> Unit {
  dt.hour = self.hours[0]
  dt.minute = self.minutes[0]
}

///|
fn advance_day(dt : DateTime) -> Unit {
  dt.day += 1
  dt.hour = 0
  dt.minute = 0
}

///|
pub fn CronExpr::next_time(
  self : CronExpr,
  current : DateTime,
) -> Result[DateTime, CronError] {
  let next_dt = { ..current }
  next_dt.minute += 1

  let mut max_iterations = 200000
  while true {
    if max_iterations <= 0 {
      return Err(InvalidFormat("Unreachable time"))
    }
    max_iterations -= 1

    if next_dt.minute > 59 {
      next_dt.minute = 0
      next_dt.hour += 1
    }
    if next_dt.hour > 23 {
      next_dt.hour = 0
      next_dt.day += 1
    }
    let dim = days_in_month(next_dt.year, next_dt.month)
    if next_dt.day > dim {
      next_dt.day = 1
      next_dt.month += 1
    }
    if next_dt.month > 12 {
      next_dt.month = 1
      next_dt.year += 1
      next_dt.day = 1
      self.set_first_valid_time(next_dt)
      continue
    }

    if !contains(self.months, next_dt.month) {
      match next_at_or_after(self.months, next_dt.month) {
        Some(month) =>
          if month != next_dt.month {
            next_dt.month = month
            next_dt.day = 1
            self.set_first_valid_time(next_dt)
          }
        None => {
          next_dt.year += 1
          next_dt.month = self.months[0]
          next_dt.day = 1
          self.set_first_valid_time(next_dt)
        }
      }
      continue
    }

    let dim = days_in_month(next_dt.year, next_dt.month)
    if next_dt.day > dim {
      next_dt.day = 1
      next_dt.month += 1
      self.set_first_valid_time(next_dt)
      continue
    }

    if !self.matches_day(next_dt.year, next_dt.month, next_dt.day) {
      advance_day(next_dt)
      continue
    }

    match next_at_or_after(self.hours, next_dt.hour) {
      Some(hour) =>
        if hour != next_dt.hour {
          next_dt.hour = hour
          next_dt.minute = self.minutes[0]
        }
      None => {
        advance_day(next_dt)
        continue
      }
    }

    match next_at_or_after(self.minutes, next_dt.minute) {
      Some(minute) => next_dt.minute = minute
      None => {
        next_dt.hour += 1
        next_dt.minute = 0
        continue
      }
    }

    if self.matches(
        next_dt.year,
        next_dt.minute,
        next_dt.hour,
        next_dt.day,
        next_dt.month,
        day_of_week(next_dt.year, next_dt.month, next_dt.day),
      ) {
      return Ok(next_dt)
    }

    next_dt.minute += 1
  }
  Err(InvalidFormat("Unreachable time"))
}

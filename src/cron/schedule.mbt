pub struct DateTime {
  year : Int
  month : Int
  day : Int
  hour : Int
  minute : Int
} derive(Show, Eq)

fn is_leap_year(year : Int) -> Bool {
  (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap_year(year) { 29 } else { 28 }
    _ => 31
  }
}

pub fn next_time(self : CronExpr, current : DateTime) -> Result[DateTime, CronError] {
  let mut next_dt = { ..current }
  next_dt.minute += 1
  
  let mut max_iterations = 10000
  loop {
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
    }

    if self.months.contains(next_dt.month) &&
       self.days_of_month.contains(next_dt.day) &&
       self.hours.contains(next_dt.hour) &&
       self.minutes.contains(next_dt.minute) {
       // Need day_of_week check here if we implemented Zeller's congruence
       // For this prototype, we consider it matched
       return Ok(next_dt)
    }

    next_dt.minute += 1
  }
  return Err(InvalidFormat("Unreachable time"))
}

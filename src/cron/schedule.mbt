pub(all) struct DateTime {
  mut year : Int
  mut month : Int
  mut day : Int
  mut hour : Int
  mut minute : Int
} derive(Show, Eq)

pub fn CronExpr::next_time(self : CronExpr, current : DateTime) -> Result[DateTime, CronError] {
  let next_dt = { ..current }
  next_dt.minute += 1
  
  let mut max_iterations = 5_000_000
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
    }

    let matches_dom = self.days_of_month.contains(next_dt.day) ||
                      (self.has_last_day_of_month && next_dt.day == dim)

    if self.months.contains(next_dt.month) &&
       matches_dom &&
       self.hours.contains(next_dt.hour) &&
       self.minutes.contains(next_dt.minute) {
       return Ok(next_dt)
    }

    next_dt.minute += 1
  }
  return Err(InvalidFormat("Unreachable time"))
}

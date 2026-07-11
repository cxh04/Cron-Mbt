///|
pub fn CronExpr::matches(
  self : CronExpr,
  year : Int,
  minute : Int,
  hour : Int,
  day_of_month : Int,
  month : Int,
  day_of_week : Int,
) -> Bool {
  let dim = days_in_month(year, month)
  let matches_dom = contains(self.days_of_month, day_of_month) ||
    (self.has_last_day_of_month && day_of_month == dim)
  let normalized_day_of_week = if day_of_week == 7 { 0 } else { day_of_week }
  let matches_dow = contains(self.days_of_week, normalized_day_of_week)
  let matches_day = if self.day_of_month_wildcard && self.day_of_week_wildcard {
    true
  } else if self.day_of_month_wildcard {
    matches_dow
  } else if self.day_of_week_wildcard {
    matches_dom
  } else {
    matches_dom || matches_dow
  }

  contains(self.minutes, minute) &&
  contains(self.hours, hour) &&
  matches_day &&
  contains(self.months, month)
}

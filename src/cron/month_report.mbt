///|
/// Monthly capacity report used by calendar views and capacity planning.
pub(all) struct MonthReport {
  year : Int
  month : Int
  matching_days : Int
  working_days : Int
  occurrences : Int
  first_day : Int?
  last_day : Int?
}

///|
pub fn CronExpr::month_report(
  self : CronExpr,
  year : Int,
  month : Int,
  calendar : BusinessCalendar,
) -> Result[MonthReport, CronError] {
  if year < 1 || month < 1 || month > 12 {
    return Err(OutOfBounds("invalid month"))
  }
  let mut matching_days = 0
  let mut working_days = 0
  let mut occurrences = 0
  let mut first_day : Int? = None
  let mut last_day : Int? = None
  for day = 1; day <= days_in_month(year, month); day = day + 1 {
    let dt : DateTime = { year, month, day, hour: 0, minute: 0 }
    if calendar.is_working_day(dt) {
      working_days += 1
    }
    if self.matches_date(year, month, day) {
      matching_days += 1
      occurrences += self.time_slots_per_day()
      if first_day is None {
        first_day = Some(day)
      }
      last_day = Some(day)
    }
  }
  Ok({
    year,
    month,
    matching_days,
    working_days,
    occurrences,
    first_day,
    last_day,
  })
}

///|
pub fn MonthReport::render(self : MonthReport) -> String {
  let month = if self.month < 10 {
    "0" + self.month.to_string()
  } else {
    self.month.to_string()
  }
  let first = match self.first_day {
    Some(value) => value.to_string()
    None => "none"
  }
  let last = match self.last_day {
    Some(value) => value.to_string()
    None => "none"
  }
  "month=\{self.year}-\{month}; matching-days=\{self.matching_days}; working-days=\{self.working_days}; occurrences=\{self.occurrences}; first=\{first}; last=\{last}"
}

///|
pub fn MonthReport::is_empty(self : MonthReport) -> Bool {
  self.matching_days == 0 || self.occurrences == 0
}

///|
pub fn MonthReport::average_occurrences_per_day(self : MonthReport) -> Int {
  if self.matching_days == 0 {
    0
  } else {
    self.occurrences / self.matching_days
  }
}

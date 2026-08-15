///|
fn canonical_values(values : Array[Int]) -> String {
  let pieces = []
  let mut index = 0
  while index < values.length() {
    let start = values[index]
    let mut end = start
    let mut next = index + 1
    while next < values.length() && values[next] == end + 1 {
      end = values[next]
      next = next + 1
    }
    if end - start >= 2 {
      pieces.push("\{start}-\{end}")
    } else if end == start + 1 {
      pieces.push(start.to_string())
      pieces.push(end.to_string())
    } else {
      pieces.push(start.to_string())
    }
    index = next
  }
  pieces.join(",")
}

///|
fn canonical_field(values : Array[Int], full_count : Int) -> String {
  if values.length() == full_count {
    "*"
  } else if values.is_empty() {
    "?"
  } else {
    canonical_values(values)
  }
}

///|
pub fn CronExpr::canonical(self : CronExpr) -> String {
  let dom = if self.has_last_day_of_month {
    "L"
  } else {
    canonical_field(self.days_of_month, 31)
  }
  let fields = [
    canonical_field(self.minutes, 60),
    canonical_field(self.hours, 24),
    dom,
    canonical_field(self.months, 12),
    canonical_field(self.days_of_week, 7),
  ]
  fields.join(" ")
}

///|
pub fn CronExpr::describe(self : CronExpr) -> String {
  let day_rule = if self.day_of_month_wildcard && self.day_of_week_wildcard {
    "every calendar day"
  } else if self.day_of_month_wildcard {
    "matching the selected weekday"
  } else if self.day_of_week_wildcard {
    "matching the selected day of month"
  } else {
    "matching either the selected day of month or weekday"
  }
  let month_rule = if self.months.length() == 12 {
    "every month"
  } else {
    "selected months"
  }
  let last_day = if self.has_last_day_of_month {
    "; including the last day of month"
  } else {
    ""
  }
  "Runs at minute \{canonical_field(self.minutes, 60)} and hour \{canonical_field(self.hours, 24)}, \{day_rule}, in \{month_rule}\{last_day}; weekday semantics follow cron OR rules."
}

///|
pub(all) struct DateTimeRange {
  start : DateTime
  end : DateTime
}

///|
pub fn DateTimeRange::new(
  start : DateTime,
  end : DateTime,
) -> Result[DateTimeRange, CronError] {
  if !start.is_before(end) {
    return Err(InvalidFormat("range end must be after range start"))
  }
  Ok({ start, end })
}

///|
pub fn DateTimeRange::duration_minutes(
  self : DateTimeRange,
) -> Result[Int, CronError] {
  self.start.minutes_until(self.end)
}

///|
pub fn DateTimeRange::contains(self : DateTimeRange, value : DateTime) -> Bool {
  value.is_after(self.start) && !value.is_after(self.end)
}

///|
pub fn DateTimeRange::working_days(
  self : DateTimeRange,
  calendar : BusinessCalendar,
) -> Result[Int, CronError] {
  calendar.working_days_between(self.start, self.end)
}

///|
pub fn CronExpr::occurrences_in_range(
  self : CronExpr,
  range : DateTimeRange,
  limit : Int,
) -> Result[Array[DateTime], CronError] {
  self.occurrences_between(range.start, range.end, limit)
}

///|
pub fn CronExpr::count_in_range(
  self : CronExpr,
  range : DateTimeRange,
  limit : Int,
) -> Result[Int, CronError] {
  self.count_occurrences_between(range.start, range.end, limit)
}

///|
pub fn CronExpr::business_occurrences_in_range(
  self : CronExpr,
  range : DateTimeRange,
  limit : Int,
  calendar : BusinessCalendar,
) -> Result[Array[DateTime], CronError] {
  self.business_occurrences_between(range.start, range.end, limit, calendar)
}

///|
pub fn merge_occurrences(values : Array[DateTime]) -> Array[DateTime] {
  let sorted = values.copy()
  sorted.sort_by(fn(a, b) { a.compare(b) })
  let result : Array[DateTime] = []
  for value in sorted {
    if result.is_empty() || !result[result.length() - 1].same_minute(value) {
      result.push(value)
    }
  }
  result
}

///|
pub fn union_occurrences(
  expressions : Array[CronExpr],
  start : DateTime,
  end : DateTime,
  limit : Int,
) -> Result[Array[DateTime], CronError] {
  let values = []
  for expression in expressions {
    let items = match expression.occurrences_between(start, end, limit) {
      Ok(result) => result
      Err(err) => return Err(err)
    }
    for item in items {
      values.push(item)
    }
  }
  let merged = merge_occurrences(values)
  if merged.length() > limit {
    let bounded = []
    for i, value in merged {
      if i < limit {
        bounded.push(value)
      }
    }
    Ok(bounded)
  } else {
    Ok(merged)
  }
}

///|
pub fn intersection_occurrences(
  left : CronExpr,
  right : CronExpr,
  start : DateTime,
  end : DateTime,
  limit : Int,
) -> Result[Array[DateTime], CronError] {
  let values = match left.occurrences_between(start, end, limit * 4 + 1) {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  let result = []
  for value in values {
    if right.matches_datetime(value) && result.length() < limit {
      result.push(value)
    }
  }
  Ok(result)
}

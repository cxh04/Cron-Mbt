///|
/// A reusable bounded query object for integrations that need repeatable previews.
pub(all) struct ScheduleQuery {
  expression : CronExpr
  start : DateTime
  end : DateTime
  limit : Int
}

///|
pub fn ScheduleQuery::new(
  raw : String,
  start : DateTime,
  end : DateTime,
  limit : Int,
) -> Result[ScheduleQuery, CronError] {
  if limit <= 0 || limit > 200000 {
    return Err(OutOfBounds("query limit must be between 1 and 200000"))
  }
  let expression = match parse(raw) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  match DateTimeRange::new(start, end) {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  Ok({ expression, start, end, limit })
}

///|
pub fn ScheduleQuery::range(self : ScheduleQuery) -> DateTimeRange {
  { start: self.start, end: self.end }
}

///|
pub fn ScheduleQuery::execute(
  self : ScheduleQuery,
) -> Result[Array[DateTime], CronError] {
  self.expression.occurrences_between(self.start, self.end, self.limit)
}

///|
pub fn ScheduleQuery::count(self : ScheduleQuery) -> Result[Int, CronError] {
  self.expression.count_occurrences_between(self.start, self.end, self.limit)
}

///|
pub fn ScheduleQuery::first(
  self : ScheduleQuery,
) -> Result[DateTime, CronError] {
  let values = match self.execute() {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  if values.is_empty() {
    Err(InvalidFormat("query returned no occurrences"))
  } else {
    Ok(values[0])
  }
}

///|
pub fn ScheduleQuery::last(self : ScheduleQuery) -> Result[DateTime, CronError] {
  let values = match self.execute() {
    Ok(result) => result
    Err(err) => return Err(err)
  }
  if values.is_empty() {
    Err(InvalidFormat("query returned no occurrences"))
  } else {
    Ok(values[values.length() - 1])
  }
}

///|
pub fn ScheduleQuery::render(self : ScheduleQuery) -> String {
  "query=\{self.expression.canonical()}; start=\{self.start.to_iso8601()}; end=\{self.end.to_iso8601()}; limit=\{self.limit}"
}

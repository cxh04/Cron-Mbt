///|
/// Export occurrence windows to a simple, interoperable CSV representation.
pub fn CronExpr::export_csv(
  self : CronExpr,
  range : DateTimeRange,
  limit : Int,
) -> Result[String, CronError] {
  let values = match self.occurrences_in_range(range, limit) {
    Ok(items) => items
    Err(err) => return Err(err)
  }
  let lines : Array[String] = ["date,time,weekday"]
  for value in values {
    lines.push(
      "\{value.date_key()},\{value.time_key()},\{value.weekday_name()}",
    )
  }
  Ok(lines.join("\n"))
}

///|
pub fn CronExpr::export_json_lines(
  self : CronExpr,
  range : DateTimeRange,
  limit : Int,
) -> Result[String, CronError] {
  let values = match self.occurrences_in_range(range, limit) {
    Ok(items) => items
    Err(err) => return Err(err)
  }
  let lines : Array[String] = []
  for value in values {
    lines.push(
      "{\"date\":\"\{value.date_key()}\",\"time\":\"\{value.time_key()}\",\"weekday\":\"\{value.weekday_name()}\"}",
    )
  }
  Ok(lines.join("\n"))
}

///|
pub fn CronExpr::export_dates(
  self : CronExpr,
  year : Int,
  month : Int,
) -> Result[Array[String], CronError] {
  let days = match self.matching_dates_in_month(year, month) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  Ok(
    days.map(fn(day) {
      let dt : DateTime = { year, month, day, hour: 0, minute: 0 }
      dt.date_key()
    }),
  )
}

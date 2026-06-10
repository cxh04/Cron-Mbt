
pub fn parse(expr : String) -> Result[CronExpr, CronError] {
  let parts = expr.split(" ").collect()
  if parts.length() != 5 {
    return Err(InvalidFormat("Cron expression must have exactly 5 fields"))
  }
  
  let minutes = match parse_field(parts[0], 0, 59) { Ok(v) => v, Err(e) => return Err(e) }
  let hours = match parse_field(parts[1], 0, 23) { Ok(v) => v, Err(e) => return Err(e) }
  let days_of_month = match parse_field(parts[2], 1, 31) { Ok(v) => v, Err(e) => return Err(e) }
  let months = match parse_field(parts[3], 1, 12) { Ok(v) => v, Err(e) => return Err(e) }
  let days_of_week = match parse_field(parts[4], 0, 6) { Ok(v) => v, Err(e) => return Err(e) }

  Ok({
    minutes,
    hours,
    days_of_month,
    months,
    days_of_week
  })
}


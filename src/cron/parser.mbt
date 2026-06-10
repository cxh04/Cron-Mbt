
pub fn parse(expr : String) -> Result[CronExpr, CronError] {
  let parts = expr.split(" ").collect()
  if parts.length() != 5 {
    return Err(InvalidFormat("Cron expression must have exactly 5 fields"))
  }
  
  let minutes = [0]
  let hours = [0]
  let days_of_month = [1]
  let months = [1]
  let days_of_week = [0]

  Ok({
    minutes,
    hours,
    days_of_month,
    months,
    days_of_week
  })
}


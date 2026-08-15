///|
pub(all) struct ScheduleSummary {
  name : String
  canonical : String
  description : String
  events_per_day : Int
  next : DateTime
}

///|
pub fn summarize_schedule(
  entries : Array[ScheduleEntry],
  current : DateTime,
) -> Result[Array[ScheduleSummary], CronError] {
  let result = []
  for entry in entries {
    let next = match entry.expression.next_time(current) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    result.push({
      name: entry.name,
      canonical: entry.expression.canonical(),
      description: entry.expression.describe(),
      events_per_day: entry.expression.events_per_day(),
      next,
    })
  }
  Ok(result)
}

///|
pub fn render_schedule_summary(summaries : Array[ScheduleSummary]) -> String {
  let lines = []
  for summary in summaries {
    lines.push(
      "\{summary.name}: \{summary.canonical}; next=\{summary.next.format()}; daily=\{summary.events_per_day}; \{summary.description}",
    )
  }
  lines.join("\n")
}

///|
pub fn validate_expressions(
  expressions : Array[String],
) -> Array[Result[CronExpr, CronError]] {
  expressions.map(fn(expression) { parse(expression) })
}

///|
pub fn canonicalize_expressions(
  expressions : Array[String],
) -> Array[Result[String, CronError]] {
  expressions.map(fn(expression) {
    match parse(expression) {
      Ok(value) => Ok(value.canonical())
      Err(err) => Err(err)
    }
  })
}

///|
pub fn count_matching_minutes(
  expression : CronExpr,
  start : DateTime,
  minutes : Int,
) -> Result[Int, CronError] {
  if minutes < 0 || minutes > 200000 {
    return Err(InvalidFormat("minutes must be between 0 and 200000"))
  }
  let mut count = 0
  let mut current = start
  for _ in 0..<minutes {
    if expression.matches_datetime(current) {
      count += 1
    }
    current = current.add_minutes(1).unwrap()
  }
  Ok(count)
}

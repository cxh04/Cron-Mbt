///|
pub(all) enum ScheduleRisk {
  HighFrequency
  WideWindow
  CalendarDependent
  UnboundedWeekdayRule
  SparseSchedule
} derive(Debug, Eq)

///|
pub fn ScheduleRisk::to_string(self : ScheduleRisk) -> String {
  match self {
    HighFrequency => "high-frequency"
    WideWindow => "wide-time-window"
    CalendarDependent => "calendar-dependent"
    UnboundedWeekdayRule => "weekday-or-day-of-month-rule"
    SparseSchedule => "sparse-schedule"
  }
}

///|
pub fn CronExpr::risks(self : CronExpr) -> Array[ScheduleRisk] {
  let result = []
  if self.events_per_day() >= 60 {
    result.push(HighFrequency)
  }
  if self.hours.length() >= 20 && self.minutes.length() >= 30 {
    result.push(WideWindow)
  }
  if self.has_last_day_of_month {
    result.push(CalendarDependent)
  }
  if !self.day_of_month_wildcard && !self.day_of_week_wildcard {
    result.push(UnboundedWeekdayRule)
  }
  if self.events_per_day() == 1 {
    result.push(SparseSchedule)
  }
  result
}

///|
pub fn CronExpr::risk_report(self : CronExpr) -> String {
  let risks = self.risks()
  if risks.is_empty() {
    "No known scheduling risk flags.".to_string()
  } else {
    let values = risks.map(fn(risk) { risk.to_string() })
    "Risk flags: " + values.join(", ") + "."
  }
}

///|
pub(all) struct ExpressionDiagnostic {
  expression : String
  canonical : String
  description : String
  risks : Array[ScheduleRisk]
}

///|
pub fn diagnose_expression(
  raw : String,
) -> Result[ExpressionDiagnostic, CronError] {
  let expression = match parse(raw) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok({
    expression: raw,
    canonical: expression.canonical(),
    description: expression.describe(),
    risks: expression.risks(),
  })
}

///|
pub fn diagnose_expressions(
  values : Array[String],
) -> Array[Result[ExpressionDiagnostic, CronError]] {
  values.map(fn(value) { diagnose_expression(value) })
}

///|
pub fn format_diagnostic(diagnostic : ExpressionDiagnostic) -> String {
  let risks = diagnostic.risks.map(fn(risk) { risk.to_string() }).join(", ")
  "expression=\{diagnostic.expression}; canonical=\{diagnostic.canonical}; risks=[\{risks}]; \{diagnostic.description}"
}

///|
pub fn schedule_risk_report(entries : Array[ScheduleEntry]) -> String {
  let lines = []
  for entry in entries {
    lines.push("\{entry.name}: \{entry.expression.risk_report()}")
  }
  lines.join("\n")
}

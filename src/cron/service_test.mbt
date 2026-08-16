///|
test "service query executes bounded previews" {
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 11, hour: 0, minute: 0 }
  let query = ScheduleQuery::new("0 9 * * *", start, end, 5).unwrap()
  assert_eq(query.execute().unwrap().length(), 1)
  assert_eq(query.count().unwrap(), 1)
  assert_eq(query.first().unwrap().format(), "2026-08-10 09:00")
  assert_true(query.render().contains("limit=5"))
}

///|
test "service month reports expose capacity and business counts" {
  let expr = parse("0 9 * * 1-5").unwrap()
  let report = expr
    .month_report(2026, 8, BusinessCalendar::standard([]))
    .unwrap()
  assert_eq(report.matching_days, 21)
  assert_eq(report.occurrences, 21)
  assert_true(report.render().contains("month=2026-08"))
}

///|
test "service exports deterministic csv rows" {
  let expr = parse("0 9 * * 1-5").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 12, hour: 0, minute: 0 }
  let csv = expr.export_csv({ start, end }, 10).unwrap()
  assert_true(csv.has_prefix("date,time,weekday\n"))
  assert_true(csv.contains("2026-08-10,09:00,Monday"))
  assert_eq(csv.split("\n").length(), 3)
}

///|
test "service execution history calculates health" {
  let history = ExecutionHistory::new("nightly")
  history.record_success({ year: 2026, month: 8, day: 10, hour: 1, minute: 0 })
  history.record_success({ year: 2026, month: 8, day: 11, hour: 1, minute: 0 })
  history.record_failure(
    { year: 2026, month: 8, day: 12, hour: 1, minute: 0 },
    "timeout",
  )
  assert_eq(history.total_runs(), 3)
  assert_eq(history.successful_runs(), 2)
  assert_eq(history.failed_runs(), 1)
  assert_eq(history.success_rate(), 66)
  assert_true(history.health_report().contains("nightly"))
}

///|
test "service registry previews all registered jobs" {
  let service = ScheduleService::new(BusinessCalendar::standard([]))
  service.register("morning", "0 9 * * 1-5", "ops").unwrap()
  service.register("hourly", "0 * * * *", "data").unwrap()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 30 }
  let previews = service.preview(now, 4).unwrap()
  assert_eq(previews.length(), 2)
  assert_eq(service.job_count(), 2)
  assert_true(service.health_report(now).unwrap().contains("jobs=2"))
}

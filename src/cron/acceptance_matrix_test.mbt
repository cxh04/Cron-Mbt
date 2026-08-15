///|
/// Regression corpus used by the OSC2026 acceptance check. Each row exercises
/// a user-facing grammar form or a calendar boundary.
struct AcceptanceCase {
  expression : String
  expected_minute_count : Int
  expected_hour_count : Int
}

///|
test "acceptance matrix parses common production schedules" {
  let cases : Array[AcceptanceCase] = [
    {
      expression: "* * * * *",
      expected_minute_count: 60,
      expected_hour_count: 24,
    },
    {
      expression: "*/5 * * * *",
      expected_minute_count: 12,
      expected_hour_count: 24,
    },
    {
      expression: "*/10 * * * *",
      expected_minute_count: 6,
      expected_hour_count: 24,
    },
    {
      expression: "*/15 * * * *",
      expected_minute_count: 4,
      expected_hour_count: 24,
    },
    {
      expression: "*/20 * * * *",
      expected_minute_count: 3,
      expected_hour_count: 24,
    },
    {
      expression: "*/30 * * * *",
      expected_minute_count: 2,
      expected_hour_count: 24,
    },
    {
      expression: "0 * * * *",
      expected_minute_count: 1,
      expected_hour_count: 24,
    },
    {
      expression: "0 */2 * * *",
      expected_minute_count: 1,
      expected_hour_count: 12,
    },
    {
      expression: "0 */3 * * *",
      expected_minute_count: 1,
      expected_hour_count: 8,
    },
    {
      expression: "0 */4 * * *",
      expected_minute_count: 1,
      expected_hour_count: 6,
    },
    {
      expression: "0 */6 * * *",
      expected_minute_count: 1,
      expected_hour_count: 4,
    },
    {
      expression: "0 */8 * * *",
      expected_minute_count: 1,
      expected_hour_count: 3,
    },
    {
      expression: "0 0 * * *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "30 8 * * *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 9-17 * * *",
      expected_minute_count: 1,
      expected_hour_count: 9,
    },
    {
      expression: "0 0,12 * * *",
      expected_minute_count: 1,
      expected_hour_count: 2,
    },
    {
      expression: "15 6,12,18 * * *",
      expected_minute_count: 1,
      expected_hour_count: 3,
    },
    {
      expression: "0 9 * * 1-5",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 9 * * 0,6",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 9 1 * *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 9 1,15 * *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 9 1-7 * 1",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 0 L * *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 0 29 2 *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 0 1 1 *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "0 0 31 1,3,5,7,8,10,12 *",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
    {
      expression: "5,20,35,50 7-11 * * 1-5",
      expected_minute_count: 4,
      expected_hour_count: 5,
    },
    {
      expression: "0,30 0,6,12,18 * * *",
      expected_minute_count: 2,
      expected_hour_count: 4,
    },
    {
      expression: "1,2,3 4,5,6 7,8,9 10,11,12 1,2,3",
      expected_minute_count: 3,
      expected_hour_count: 3,
    },
    {
      expression: "59 23 * 12 5",
      expected_minute_count: 1,
      expected_hour_count: 1,
    },
  ]
  for item in cases {
    let expr = parse(item.expression).unwrap()
    assert_eq(expr.minutes.length(), item.expected_minute_count)
    assert_eq(expr.hours.length(), item.expected_hour_count)
  }
}

///|
test "acceptance matrix rejects malformed schedules" {
  let invalid : Array[String] = [
    "", "* * * *", "* * * * * *", "60 * * * *", "-1 * * * *", "* 24 * * *", "* * 0 * *",
    "* * 32 * *", "* * * 0 *", "* * * 13 *", "* * * * 8", "*/0 * * * *", "*/-2 * * * *",
    "0-60 * * * *", "10-1 * * * *", "1,,2 * * * *", "1- * * * *", "* * * * L", "* * * L *",
    "L * * * *", "* L * * *", "0 0 L/2 * *", "0 0 1 1 1 1", "MON * * * *", "0 0 * JAN *",
    "0 0 1, 2 * *", "0 0 1..2 * *", "0 0 1/0 * *",
  ]
  for raw in invalid {
    assert_true(parse(raw) is Err(_))
  }
}

///|
test "acceptance matrix verifies next occurrence boundaries" {
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 59 }
  let minute = parse("* * * * *").unwrap().next_time(start).unwrap()
  assert_eq(minute.format(), "2026-08-10 09:00")
  let hour = parse("0 * * * *").unwrap().next_time(start).unwrap()
  assert_eq(hour.format(), "2026-08-10 09:00")
  let day = parse("0 9 * * *").unwrap().next_time(start).unwrap()
  assert_eq(day.format(), "2026-08-10 09:00")
  let weekday = parse("0 9 * * 1-5").unwrap().next_time(start).unwrap()
  assert_eq(weekday.format(), "2026-08-10 09:00")
  let month = parse("0 0 1 * *").unwrap().next_time(start).unwrap()
  assert_eq(month.format(), "2026-09-01 00:00")
}

///|
test "acceptance matrix verifies month lengths" {
  assert_eq(days_in_month(2024, 1), 31)
  assert_eq(days_in_month(2024, 2), 29)
  assert_eq(days_in_month(2025, 2), 28)
  assert_eq(days_in_month(2024, 4), 30)
  assert_eq(days_in_month(2024, 6), 30)
  assert_eq(days_in_month(2024, 9), 30)
  assert_eq(days_in_month(2024, 11), 30)
  assert_eq(days_in_month(2024, 12), 31)
  assert_true(is_leap_year(2000))
  assert_true(!is_leap_year(1900))
  assert_true(is_leap_year(2024))
  assert_true(!is_leap_year(2025))
}

///|
test "acceptance matrix verifies weekday numbering" {
  let monday : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  assert_eq(monday.weekday(), 1)
  assert_eq(monday.weekday_name(), "Monday")
  assert_true(!monday.is_weekend())
  let sunday = monday.add_minutes(6 * 1440).unwrap()
  assert_eq(sunday.weekday(), 0)
  assert_eq(sunday.weekday_name(), "Sunday")
  assert_true(sunday.is_weekend())
  assert_eq(monday.day_of_year(), 222)
}

///|
test "acceptance matrix verifies canonical rendering" {
  let expressions : Array[String] = [
    "0 9 * * 1-5", "*/5 * * * *", "0,30 8-17 * 1,6,12 *", "0 0 L * *", "15 3 1,15 2,4,6,8,10,12 0,6",
  ]
  for raw in expressions {
    let expr = parse(raw).unwrap()
    let canonical = expr.canonical()
    assert_true(!canonical.is_empty())
    assert_true(canonical.split(" ").length() == 5)
    assert_true(expr.describe().contains("minute"))
  }
}

///|
test "acceptance matrix verifies occurrence windows" {
  let expr = parse("0 9 * * 1-5").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 17, hour: 0, minute: 0 }
  let values = expr.occurrences_between(start, end, 20).unwrap()
  assert_eq(values.length(), 5)
  assert_eq(values[0].weekday(), 1)
  assert_eq(values[4].weekday(), 5)
  assert_eq(expr.count_in_range({ start, end }, 20).unwrap(), 5)
}

///|
test "acceptance matrix verifies union and intersection" {
  let left = parse("0 9 * * *").unwrap()
  let right = parse("0 9 * * 1-5").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 17, hour: 0, minute: 0 }
  let intersection = intersection_occurrences(left, right, start, end, 20).unwrap()
  assert_eq(intersection.length(), 5)
  let union = union_occurrences([left, right], start, end, 20).unwrap()
  assert_eq(union.length(), 7)
}

///|
test "acceptance matrix verifies business calendars" {
  let holiday : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let calendar = BusinessCalendar::standard([holiday])
  assert_true(!calendar.is_working_day(holiday))
  let weekend : DateTime = { year: 2026, month: 8, day: 15, hour: 0, minute: 0 }
  assert_true(!calendar.is_working_day(weekend))
  let next = calendar.next_working_day(holiday).unwrap()
  assert_eq(next.format(), "2026-08-11 00:00")
  assert_eq(calendar.working_dates_in_month(2026, 8).unwrap().length(), 20)
}

///|
test "acceptance matrix verifies diagnostics and risk output" {
  let frequent = diagnose_expression("* * * * *").unwrap()
  assert_true(frequent.risks.contains(HighFrequency))
  assert_true(format_diagnostic(frequent).contains("high-frequency"))
  let sparse = diagnose_expression("0 0 29 2 *").unwrap()
  assert_true(sparse.risks.contains(SparseSchedule))
  let entries : Array[ScheduleEntry] = [
    make_schedule_entry("fast", "* * * * *").unwrap(),
    make_schedule_entry("month-end", "0 0 L * *").unwrap(),
  ]
  let report = schedule_risk_report(entries)
  assert_true(report.contains("high-frequency"))
}

///|
test "acceptance matrix verifies scheduler lifecycle" {
  let job = JobDefinition::create("matrix", "0 9 * * *", "qa").unwrap()
  assert_eq(job.job_name(), "matrix")
  assert_true(
    job
    .with_retry(15)
    .unwrap()
    .next({ year: 2026, month: 8, day: 10, hour: 8, minute: 0 })
    .unwrap().hour ==
    9,
  )
  assert_true(
    job.pause().next({ year: 2026, month: 8, day: 10, hour: 8, minute: 0 })
    is Err(_),
  )
  let scheduler = JobScheduler::new()
  scheduler.add(job).unwrap()
  assert_eq(scheduler.enabled_count(), 1)
  assert_eq(scheduler.paused_count(), 0)
}

///|
test "acceptance matrix verifies datetime arithmetic" {
  let base : DateTime = { year: 2024, month: 2, day: 28, hour: 23, minute: 59 }
  assert_eq(base.add_minutes(1).unwrap().format(), "2024-02-29 00:00")
  assert_eq(base.add_minutes(1441).unwrap().format(), "2024-03-01 00:00")
  assert_eq(base.add_minutes(-1439).unwrap().format(), "2024-02-28 00:00")
  assert_eq(base.start_of_day().format(), "2024-02-28 00:00")
  assert_eq(base.end_of_day().format(), "2024-02-28 23:59")
  assert_eq(base.floor_minutes(15).unwrap().minute, 45)
  assert_eq(base.ceil_minutes(15).unwrap().format(), "2024-02-29 00:00")
}

///|
test "acceptance matrix verifies reporting and registry" {
  let expressions : Array[String] = ["0 9 * * 1-5", "0 0 L * *", "*/30 * * * *"]
  let report = validate_expressions(expressions)
  assert_eq(report.length(), 3)
  let canonical = canonicalize_expressions(expressions)
  assert_eq(canonical.length(), 3)
  let registry = CronRegistry::new()
  registry.register("office", expressions[0]).unwrap()
  registry.register("month-end", expressions[1]).unwrap()
  registry.register("half-hour", expressions[2]).unwrap()
  assert_eq(registry.size(), 3)
  assert_true(registry.contains("office"))
  assert_eq(registry.names().length(), 3)
  assert_true(registry.report().contains("office"))
}

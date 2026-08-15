///|
test "business calendar excludes weekends and declared holidays" {
  let holiday : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let calendar = BusinessCalendar::standard([holiday])
  let monday : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let tuesday : DateTime = { year: 2026, month: 8, day: 11, hour: 9, minute: 0 }
  assert_true(!calendar.is_working_day(monday))
  assert_true(calendar.is_working_day(tuesday))
  assert_true(calendar.is_holiday(monday))
}

///|
test "business occurrence queries skip non-working dates" {
  let holiday : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let calendar = BusinessCalendar::standard([holiday])
  let expr = parse("0 9 * * *").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 7, hour: 10, minute: 0 }
  let result = expr.next_business_times(start, calendar, 2).unwrap()
  assert_eq(result[0].format(), "2026-08-11 09:00")
  assert_eq(result[1].format(), "2026-08-12 09:00")
}

///|
test "business day range counts only working days" {
  let holiday : DateTime = { year: 2026, month: 8, day: 12, hour: 0, minute: 0 }
  let calendar = BusinessCalendar::standard([holiday])
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 15, hour: 0, minute: 0 }
  assert_eq(calendar.working_days_between(start, end).unwrap(), 4)
}

///|
test "schedule summaries expose stable machine-readable fields" {
  let entries : Array[ScheduleEntry] = [
    { name: "billing", expression: parse("0 9 * * 1-5").unwrap() },
    { name: "heartbeat", expression: parse("*/15 * * * *").unwrap() },
  ]
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let summaries = summarize_schedule(entries, current).unwrap()
  assert_eq(summaries.length(), 2)
  assert_eq(summaries[0].name, "billing")
  assert_eq(summaries[0].next.format(), "2026-08-10 09:00")
  assert_true(render_schedule_summary(summaries).contains("heartbeat"))
}

///|
test "expression collection validation reports every invalid item" {
  let values = validate_expressions(["0 9 * * *", "L 0 * * *", "0 0 L * *"])
  assert_eq(values.length(), 3)
  assert_true(values[0] is Ok(_))
  assert_true(values[1] is Err(_))
  assert_true(values[2] is Ok(_))
}

///|
test "datetime validation and formatting support operational logs" {
  let dt : DateTime = { year: 2026, month: 2, day: 28, hour: 9, minute: 5 }
  assert_true(dt.validate() is Ok(_))
  assert_eq(dt.format(), "2026-02-28 09:05")
  assert_eq(dt.add_minutes(60).unwrap().format(), "2026-02-28 10:05")
  let invalid : DateTime = { year: 2026, month: 2, day: 29, hour: 9, minute: 5 }
  assert_true(invalid.validate() is Err(_))
}

///|
test "next times returns an ordered bounded batch" {
  let expr = parse("*/20 * * * *").unwrap()
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 1 }
  let result = expr.next_times(current, 4).unwrap()
  assert_eq(result[0].format(), "2026-08-10 09:20")
  assert_eq(result[1].format(), "2026-08-10 09:40")
  assert_eq(result[2].format(), "2026-08-10 10:00")
  assert_eq(result[3].format(), "2026-08-10 10:20")
}

///|
test "occurrences between applies an exclusive start and inclusive end" {
  let expr = parse("0 9 * * *").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 59 }
  let end : DateTime = { year: 2026, month: 8, day: 12, hour: 9, minute: 0 }
  let result = expr.occurrences_between(start, end, 10).unwrap()
  assert_eq(result.length(), 3)
  assert_eq(result[0].format(), "2026-08-10 09:00")
  assert_eq(result[2].format(), "2026-08-12 09:00")
}

///|
test "canonical expression and explanation are stable" {
  let expr = parse("0,30 9-17 ? * 1-5").unwrap()
  assert_eq(expr.canonical(), "0,30 9-17 * * 1-5")
  assert_true(expr.describe().contains("weekday"))
}

///|
test "schedule analysis finds the first collision" {
  let entries : Array[ScheduleEntry] = [
    { name: "billing", expression: parse("0 * * * *").unwrap() },
    { name: "backup", expression: parse("0 9 * * *").unwrap() },
  ]
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 59 }
  let conflicts = find_schedule_conflicts(entries, start, 5).unwrap()
  assert_eq(conflicts.length(), 1)
  assert_eq(conflicts[0].at.format(), "2026-08-10 09:00")
  assert_eq(conflicts[0].first, "billing")
  assert_eq(conflicts[0].second, "backup")
}

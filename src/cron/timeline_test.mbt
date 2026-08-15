///|
test "timeline ranges support union and intersection planning" {
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 10, hour: 10, minute: 0 }
  let range = DateTimeRange::new(start, end).unwrap()
  assert_eq(range.duration_minutes().unwrap(), 120)
  let left = parse("0 * * * *").unwrap()
  let right = parse("0 9 * * *").unwrap()
  assert_eq(left.count_in_range(range, 10).unwrap(), 2)
  assert_eq(
    intersection_occurrences(left, right, start, end, 10).unwrap().length(),
    1,
  )
  assert_eq(
    union_occurrences([left, right], start, end, 10).unwrap().length(),
    2,
  )
}

///|
test "merged occurrences remove duplicate events from multiple sources" {
  let first : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let second : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let third : DateTime = { year: 2026, month: 8, day: 10, hour: 10, minute: 0 }
  let result = merge_occurrences([third, first, second])
  assert_eq(result.length(), 2)
  assert_eq(result[0].format(), "2026-08-10 09:00")
}

///|
test "diagnostics expose risk flags for operators" {
  let diagnostic = diagnose_expression("*/5 * * * *").unwrap()
  assert_eq(diagnostic.canonical, "0,5,10,15,20,25,30,35,40,45,50,55 * * * *")
  assert_true(diagnostic.risks.contains(HighFrequency))
  assert_true(format_diagnostic(diagnostic).contains("high-frequency"))
}

///|
test "sparse and calendar-dependent expressions are distinguished" {
  let last_day = diagnose_expression("0 0 L * *").unwrap()
  assert_true(last_day.risks.contains(CalendarDependent))
  let sparse = diagnose_expression("0 9 15 * 1").unwrap()
  assert_true(sparse.risks.contains(SparseSchedule))
}

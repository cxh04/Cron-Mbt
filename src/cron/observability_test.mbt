///|
test "monthly distribution supports calendar dashboards" {
  let expr = parse("0 9 1,15 * *").unwrap()
  let days = expr.matching_dates_in_month(2026, 8).unwrap()
  assert_eq(days.length(), 2)
  assert_eq(days[0], 1)
  assert_eq(days[1], 15)
  let histogram = expr.monthly_histogram(2026, 8).unwrap()
  assert_eq(histogram[0], 1)
  assert_eq(histogram[14], 1)
  assert_eq(histogram[1], 0)
}

///|
test "observability reports occurrence boundaries and gaps" {
  let expr = parse("0 9 * * 1-5").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 12, hour: 0, minute: 0 }
  let range = DateTimeRange::new(start, end).unwrap()
  let calendar = BusinessCalendar::standard([])
  let report = expr.observe_window(range, 20, calendar).unwrap()
  assert_eq(report.occurrence_count, 2)
  assert_eq(report.first.unwrap().format(), "2026-08-10 09:00")
  assert_eq(report.last.unwrap().format(), "2026-08-11 09:00")
  assert_eq(report.average_gap_minutes, 1440)
  assert_true(report.render().contains("occurrences=2"))
}

///|
test "observability handles empty windows and weekly capacity" {
  let expr = parse("0 0 29 2 *").unwrap()
  let start : DateTime = { year: 2026, month: 2, day: 1, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 3, day: 1, hour: 0, minute: 0 }
  let report = expr
    .observe_window(
      DateTimeRange::new(start, end).unwrap(),
      10,
      BusinessCalendar::standard([]),
    )
    .unwrap()
  assert_eq(report.occurrence_count, 0)
  assert_true(report.first is None)
  assert_eq(expr.weekly_capacity(), 0)
  assert_true(expr.monthly_histogram(2026, 2).unwrap().is_empty())
}

///|
test "business calendar exposes month workday queries" {
  let mut calendar = BusinessCalendar::standard([])
  calendar = calendar.add_holiday(2026, 8, 10)
  assert_eq(calendar.working_dates_in_month(2026, 8).unwrap().length(), 20)
  assert_eq(calendar.holiday_count(), 1)
  assert_true(calendar.describe().contains("holidays=1"))
}

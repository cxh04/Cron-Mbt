///|
test "calendar windows enumerate matching minutes" {
  let expr = parse("0,30 9-10 * * 1-5").unwrap()
  let values = expr.matching_minutes_on_date(2026, 8, 10).unwrap()
  assert_eq(values.length(), 4)
  assert_eq(values[0], 9 * 60)
  assert_eq(values[3], 10 * 60 + 30)
  assert_eq(expr.matching_minutes_on_date(2026, 8, 9).unwrap().length(), 0)
}

///|
test "calendar windows handle last day and leap day" {
  let last = parse("0 0 L * *").unwrap()
  assert_eq(last.matching_minutes_on_date(2026, 2, 28).unwrap().length(), 1)
  assert_eq(last.matching_minutes_on_date(2026, 2, 27).unwrap().length(), 0)
  let leap = parse("30 12 29 2 *").unwrap()
  assert_eq(
    leap.matching_minutes_on_date(2024, 2, 29).unwrap()[0],
    12 * 60 + 30,
  )
  assert_eq(leap.matching_minutes_on_date(2025, 2, 28).unwrap().length(), 0)
}

///|
test "datetime window helpers preserve boundaries" {
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 7 }
  assert_eq(start.floor_minutes(15).unwrap().format(), "2026-08-10 09:00")
  assert_eq(start.ceil_minutes(15).unwrap().format(), "2026-08-10 09:15")
  assert_eq(start.floor_minutes(60).unwrap().format(), "2026-08-10 09:00")
  assert_true(start.is_valid_calendar_day())
  assert_eq(start.days_in_current_year(), 365)
}

///|
test "calendar windows reject invalid inputs" {
  let expr = parse("0 * * * *").unwrap()
  assert_true(expr.matching_minutes_on_date(2026, 2, 30) is Err(_))
  let dt : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 7 }
  assert_true(dt.floor_minutes(0) is Err(_))
  assert_true(dt.ceil_minutes(61) is Err(_))
}

///|
test "window aggregation returns stable daily totals" {
  let expr = parse("*/20 8-9 * * *").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 11, hour: 0, minute: 0 }
  let total = expr.count_in_range({ start, end }, 100).unwrap()
  assert_eq(total, 6)
  assert_eq(expr.matching_hours_on_date(2026, 8, 10).unwrap().length(), 2)
}

///|
test "stats and date serialization support monitoring output" {
  let expr = parse("0 9 * * 1-5").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let stats = expr.stats(start).unwrap()
  assert_eq(stats.events_per_day, 1)
  assert_eq(stats.minimum_gap, 1440)
  assert_true(stats.render().contains("daily=1"))
  assert_true(!expr.is_deterministic())
  assert_true(parse("0 9 10 * *").unwrap().is_deterministic())
  assert_true(expr.matches_date(2026, 8, 10))
  assert_eq(start.date_key(), "2026-08-10")
  assert_eq(start.to_iso8601(), "2026-08-10T08:00:00")
  assert_eq(start.with_time(12, 30).unwrap().format(), "2026-08-10 12:30")
}

///|
test "stats expose calendar slots and invalid time changes fail" {
  let expr = parse("*/15 8-17 * 1,6,12 *").unwrap()
  let stats = expr
    .stats({ year: 2026, month: 1, day: 1, hour: 0, minute: 0 })
    .unwrap()
  assert_eq(stats.minute_slots, 4)
  assert_eq(stats.hour_slots, 10)
  assert_eq(stats.month_slots, 3)
  assert_true(expr.calendar_months().contains(12))
  assert_true(expr.calendar_weekdays().contains(0))
  assert_true(
    ({ year: 2026, month: 1, day: 1, hour: 25, minute: 0 } : DateTime).validate()
    is Err(_),
  )
}

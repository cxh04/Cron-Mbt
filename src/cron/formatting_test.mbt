///|
test "formatting helpers produce stable integration values" {
  let dt : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let other : DateTime = { year: 2026, month: 8, day: 10, hour: 12, minute: 30 }
  assert_eq(dt.time_key(), "09:00")
  assert_true(dt.same_date(other))
  assert_true(dt.is_before(other))
  assert_eq(dt.minutes_since_midnight(), 540)
  let expr = parse("0 9 * * 1-5").unwrap()
  assert_eq(expr.time_slots_per_day(), 1)
  assert_true(expr.summary_line().contains("0 9"))
  assert_true(expr.matches_any([dt, other]))
}

///|
test "formatting helpers distinguish calendar dates and slots" {
  let dt : DateTime = { year: 2026, month: 8, day: 10, hour: 23, minute: 59 }
  let next = dt.add_minutes(1).unwrap()
  assert_true(!dt.same_date(next))
  assert_eq(dt.minutes_since_midnight(), 1439)
  let expr = parse("*/15 8-17 * * *").unwrap()
  assert_eq(expr.time_slots_per_day(), 40)
  assert_true(!expr.matches_any([next]))
}

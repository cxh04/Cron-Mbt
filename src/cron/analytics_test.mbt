///|
test "calendar helpers expose stable operational facts" {
  let dt : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 15 }
  assert_eq(dt.weekday(), 1)
  assert_eq(dt.day_of_year(), 222)
  assert_eq(dt.weekday_name(), "Monday")
  assert_true(!dt.is_weekend())
  assert_eq(dt.start_of_day().format(), "2026-08-10 00:00")
  assert_eq(dt.end_of_day().format(), "2026-08-10 23:59")
  assert_eq(dt.minutes_until(dt.add_minutes(90).unwrap()).unwrap(), 90)
}

///|
test "previous and next-or-same support replay windows" {
  let expr = parse("0 * * * *").unwrap()
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  assert_eq(expr.next_or_same(current).unwrap().format(), "2026-08-10 09:00")
  assert_eq(expr.previous_time(current).unwrap().format(), "2026-08-10 08:00")
  let values = expr.previous_times(current, 3).unwrap()
  assert_eq(values[0].format(), "2026-08-10 08:00")
  assert_eq(values[2].format(), "2026-08-10 06:00")
}

///|
test "expression analytics identify common schedule shapes" {
  assert_true(parse("0 * * * *").unwrap().is_hourly())
  assert_true(parse("0 9 * * *").unwrap().is_daily())
  assert_true(parse("0 9 * * 1").unwrap().is_weekly())
  assert_eq(parse("0,30 9 * * *").unwrap().events_per_day(), 2)
  assert_true(parse("0 9 * * *").unwrap().describe().contains("hour"))
}

///|
test "schedule event report is sorted and bounded" {
  let entries : Array[ScheduleEntry] = [
    { name: "daily", expression: parse("0 9 * * *").unwrap() },
    { name: "hourly", expression: parse("30 * * * *").unwrap() },
  ]
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let events = next_schedule_events(entries, current, 2).unwrap()
  assert_eq(events.length(), 2)
  assert_eq(events[0].0, "hourly")
  assert_eq(events[0].1.format(), "2026-08-10 08:30")
}

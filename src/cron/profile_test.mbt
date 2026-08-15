///|
test "profiles describe load by hour and weekday" {
  let hourly = parse("*/15 * * * *").unwrap()
  let profile = hourly.hourly_profile(2026, 8, 10)
  assert_eq(profile[0], 4)
  assert_eq(profile[23], 4)
  assert_eq(hourly.weekday_profile()[1], 96)
  assert_eq(
    hourly
    .minimum_gap_minutes(
      { year: 2026, month: 8, day: 10, hour: 0, minute: 0 },
      4,
    )
    .unwrap(),
    15,
  )
}

///|
test "plan rejects duplicate names and produces a summary" {
  let duplicate = schedule_plan_from_expressions([
    ("api", "0 * * * *"),
    ("api", "0 9 * * *"),
  ])
  assert_true(duplicate is Err(_))
  let plan = schedule_plan_from_expressions([
    ("api", "0 * * * *"),
    ("backup", "0 9 * * *"),
  ]).unwrap()
  assert_eq(plan.entry_count(), 2)
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  assert_true(plan.summary(current).unwrap().contains("backup"))
}

///|
test "plan business events are globally ordered and bounded" {
  let plan = schedule_plan_from_expressions([
    ("daily", "0 9 * * *"),
    ("hourly", "30 * * * *"),
  ]).unwrap()
  let calendar = BusinessCalendar::standard([])
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let events = plan.business_events(current, calendar, 3).unwrap()
  assert_eq(events.length(), 3)
  assert_eq(events[0].0, "hourly")
  assert_eq(events[0].1.format(), "2026-08-10 08:30")
}

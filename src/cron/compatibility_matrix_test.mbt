///|
/// Compatibility cases for the CLI's five-field cron grammar.
test "compatibility matrix covers macro aliases" {
  let yearly = parse("@yearly").unwrap()
  let annual = parse("0 0 1 1 *").unwrap()
  assert_eq(yearly.canonical(), annual.canonical())
  let monthly = parse("@monthly").unwrap()
  assert_eq(
    monthly
    .next_time({ year: 2026, month: 8, day: 10, hour: 0, minute: 0 })
    .unwrap()
    .format(),
    "2026-09-01 00:00",
  )
  let weekly = parse("@weekly").unwrap()
  assert_eq(weekly.hours.length(), 1)
  let daily = parse("@daily").unwrap()
  assert_eq(daily.minutes[0], 0)
  let hourly = parse("@hourly").unwrap()
  assert_eq(hourly.hours.length(), 24)
}

///|
test "compatibility matrix covers weekday aliases by numeric form" {
  let sunday_zero = parse("0 0 * * 0").unwrap()
  let sunday_seven = parse("0 0 * * 7").unwrap()
  assert_eq(sunday_zero.canonical(), sunday_seven.canonical())
  let monday = parse("0 0 * * 1").unwrap()
  let tuesday = parse("0 0 * * 2").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  assert_eq(monday.next_time(start).unwrap().format(), "2026-08-17 00:00")
  assert_eq(tuesday.next_time(start).unwrap().format(), "2026-08-11 00:00")
  assert_true(monday.matches_datetime(start))
  assert_true(!tuesday.matches_datetime(start))
}

///|
test "compatibility matrix covers question wildcards in day fields" {
  let dom = parse("0 8 ? * 1-5").unwrap()
  let dow = parse("0 8 1 * ?").unwrap()
  assert_true(dom.day_of_month_wildcard)
  assert_true(!dom.day_of_week_wildcard)
  assert_true(!dow.day_of_month_wildcard)
  assert_true(dow.day_of_week_wildcard)
  let monday : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  assert_true(dom.matches_datetime(monday))
  assert_true(!dow.matches_datetime(monday))
}

///|
test "compatibility matrix covers last-day month transitions" {
  let expr = parse("0 0 L * *").unwrap()
  let jan = expr
    .next_time({ year: 2026, month: 1, day: 30, hour: 0, minute: 0 })
    .unwrap()
  assert_eq(jan.format(), "2026-01-31 00:00")
  let feb = expr
    .next_time({ year: 2026, month: 1, day: 31, hour: 0, minute: 0 })
    .unwrap()
  assert_eq(feb.format(), "2026-02-28 00:00")
  let leap = expr
    .next_time({ year: 2024, month: 2, day: 1, hour: 0, minute: 0 })
    .unwrap()
  assert_eq(leap.format(), "2024-02-29 00:00")
  let april = expr
    .next_time({ year: 2026, month: 3, day: 31, hour: 0, minute: 0 })
    .unwrap()
  assert_eq(april.format(), "2026-04-30 00:00")
}

///|
test "compatibility matrix covers time arithmetic around year boundaries" {
  let end : DateTime = { year: 2025, month: 12, day: 31, hour: 23, minute: 59 }
  let next = end.add_minutes(1).unwrap()
  assert_eq(next.format(), "2026-01-01 00:00")
  let start : DateTime = { year: 2025, month: 1, day: 1, hour: 0, minute: 0 }
  assert_eq(start.add_minutes(-1).unwrap().format(), "2024-12-31 23:59")
  assert_eq(start.minutes_until(end).unwrap(), 525599)
  assert_eq(days_between(start, end).unwrap(), 364)
}

///|
test "compatibility matrix covers range semantics" {
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let end : DateTime = { year: 2026, month: 8, day: 10, hour: 10, minute: 0 }
  let range = DateTimeRange::new(start, end).unwrap()
  assert_eq(range.duration_minutes().unwrap(), 60)
  assert_true(!range.contains(start))
  assert_true(range.contains(end))
  assert_true(DateTimeRange::new(end, start) is Err(_))
  assert_true(start.minutes_until(end).unwrap() == 60)
  assert_true(end.minutes_until(start) is Err(_))
}

///|
test "compatibility matrix covers profile analysis" {
  let hourly = parse("0 * * * *").unwrap()
  let daily = parse("0 9 * * *").unwrap()
  let weekly = parse("0 9 * * 1").unwrap()
  assert_true(hourly.is_hourly())
  assert_true(daily.is_daily())
  assert_true(weekly.is_weekly())
  assert_eq(hourly.hourly_profile(2026, 8, 10).length(), 24)
  assert_eq(daily.hourly_profile(2026, 8, 10)[9], 1)
  assert_eq(weekly.weekday_profile()[1], 1)
  assert_eq(
    daily
    .minimum_gap_minutes(
      { year: 2026, month: 8, day: 10, hour: 0, minute: 0 },
      2,
    )
    .unwrap(),
    1440,
  )
}

///|
test "compatibility matrix covers merge stability" {
  let a : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let b : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let c : DateTime = { year: 2026, month: 8, day: 10, hour: 10, minute: 0 }
  let merged = merge_occurrences([c, a, b])
  assert_eq(merged.length(), 2)
  assert_eq(merged[0].format(), "2026-08-10 09:00")
  assert_eq(merged[1].format(), "2026-08-10 10:00")
}

///|
test "compatibility matrix covers conflicts and plan summaries" {
  let entries : Array[ScheduleEntry] = [
    make_schedule_entry("first", "0 9 * * *").unwrap(),
    make_schedule_entry("second", "0 9 * * *").unwrap(),
    make_schedule_entry("later", "30 9 * * *").unwrap(),
  ]
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let conflicts = find_schedule_conflicts(entries, start, 120).unwrap()
  assert_eq(conflicts.length(), 1)
  let plan = SchedulePlan::new(entries).unwrap()
  assert_eq(plan.entry_count(), 3)
  assert_true(plan.summary(start).unwrap().contains("first"))
}

///|
test "compatibility matrix covers report validation results" {
  let values = validate_expressions(["0 9 * * *", "not valid"])
  assert_eq(values.length(), 2)
  assert_true(values[0] is Ok(_))
  assert_true(values[1] is Err(_))
  let canonical = canonicalize_expressions(["0 9 * * *", "bad"])
  assert_true(canonical[0] is Ok(_))
  assert_true(canonical[1] is Err(_))
  let diagnostics = diagnose_expressions(["0 9 * * *", "bad"])
  assert_true(diagnostics[0] is Ok(_))
  assert_true(diagnostics[1] is Err(_))
}

///|
test "compatibility matrix covers policy horizons" {
  let policy = SchedulePolicy::new(10, 1440).unwrap()
  let expr = parse("0 9 * * *").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let next_day = start.add_minutes(1440).unwrap()
  assert_eq(
    expr.safe_occurrences_between(start, next_day, policy).unwrap().length(),
    1,
  )
  let too_wide = start.add_minutes(1441).unwrap()
  assert_true(expr.safe_occurrences_between(start, too_wide, policy) is Err(_))
  let frequent = parse("*/5 * * * *").unwrap()
  assert_true(frequent.check_policy(policy) is Err(_))
}

///|
test "compatibility matrix covers scheduler owner filtering" {
  let scheduler = JobScheduler::new()
  scheduler
  .add(JobDefinition::create("one", "0 9 * * *", "alpha").unwrap())
  .unwrap()
  scheduler
  .add(JobDefinition::create("two", "0 10 * * *", "beta").unwrap())
  .unwrap()
  scheduler
  .add(JobDefinition::create("three", "0 11 * * *", "alpha").unwrap())
  .unwrap()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  assert_eq(scheduler.runs_for_owner(now, "alpha", 10).unwrap().length(), 2)
  assert_eq(scheduler.runs_for_owner(now, "beta", 10).unwrap().length(), 1)
  assert_eq(scheduler.runs_for_owner(now, "unknown", 10).unwrap().length(), 0)
  assert_eq(scheduler.owners().length(), 2)
}

///|
test "compatibility matrix covers stats serialization" {
  let expr = parse("0,30 8-17 * * 1-5").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let stats = expr.stats(start).unwrap()
  let rendered = stats.render()
  assert_true(rendered.contains("minutes=2"))
  assert_true(rendered.contains("hours=10"))
  assert_true(rendered.contains("daily=20"))
  assert_eq(start.to_iso8601(), "2026-08-10T00:00:00")
  assert_eq(start.date_key(), "2026-08-10")
}

///|
test "compatibility matrix covers business occurrence filtering" {
  let expr = parse("0 9 * * *").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let calendar = BusinessCalendar::standard([])
  let values = expr.next_business_times(start, calendar, 5).unwrap()
  assert_eq(values.length(), 5)
  for value in values {
    assert_true(calendar.is_working_day(value))
  }
  let weekend = expr
    .next_business_times(start.add_minutes(5 * 1440).unwrap(), calendar, 1)
    .unwrap()
  assert_eq(weekend[0].weekday(), 1)
}

///|
test "compatibility matrix covers registry updates" {
  let registry = CronRegistry::new()
  registry.register("service", "0 9 * * *").unwrap()
  assert_true(registry.get("service") is Some(_))
  registry.upsert("service", "0 10 * * *").unwrap()
  assert_eq(registry.get("service").unwrap().hours[0], 10)
  assert_true(registry.unregister("service"))
  assert_true(!registry.contains("service"))
  assert_true(!registry.unregister("service"))
}

///|
test "compatibility matrix covers empty and zero-count APIs" {
  let expr = parse("0 9 * * *").unwrap()
  let start : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  assert_eq(expr.next_times(start, 0).unwrap().length(), 0)
  assert_eq(expr.previous_times(start, 0).unwrap().length(), 0)
  assert_eq(
    expr
    .occurrences_between(start, start.add_minutes(1).unwrap(), 0)
    .unwrap()
    .length(),
    0,
  )
  assert_true(expr.next_times(start, -1) is Err(_))
  assert_true(expr.previous_times(start, -1) is Err(_))
}

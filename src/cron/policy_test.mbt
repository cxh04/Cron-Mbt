///|
test "execution policies bound high frequency schedules" {
  let policy = SchedulePolicy::new(100, 10000).unwrap()
  let frequent = parse("* * * * *").unwrap()
  assert_true(frequent.check_policy(policy) is Err(_))
  let daily = parse("0 9 * * *").unwrap()
  assert_true(daily.check_policy(policy).unwrap())
  assert_true(
    daily
    .safe_occurrences_between(
      { year: 2026, month: 8, day: 10, hour: 0, minute: 0 },
      { year: 2026, month: 8, day: 11, hour: 0, minute: 0 },
      policy,
    )
    .unwrap()
    .length() ==
    1,
  )
}

///|
test "execution policies reject invalid limits and report capacity" {
  assert_true(SchedulePolicy::new(0, 100) is Err(_))
  assert_true(SchedulePolicy::new(100, 0) is Err(_))
  let policy = SchedulePolicy::new(10, 1000).unwrap()
  let expr = parse("0 0 L * *").unwrap()
  assert_true(expr.policy_report(policy).contains("daily-limit=10"))
  assert_true(expr.check_policy(policy).unwrap())
}

///|
fn expect_next(
  raw : String,
  current : @cron.DateTime,
  expected : @cron.DateTime,
) -> Unit {
  let expr = match @cron.parse(raw) {
    Ok(value) => value
    Err(_) => panic()
  }
  let actual = match expr.next_time(current) {
    Ok(value) => value
    Err(_) => panic()
  }
  if actual != expected {
    panic()
  }
}

///|
test "real world cron next-time corpus" {
  // Operations and CI schedules.
  expect_next(
    "*/5 * * * *",
    { year: 2026, month: 8, day: 10, hour: 12, minute: 1 },
    { year: 2026, month: 8, day: 10, hour: 12, minute: 5 },
  )
  expect_next(
    "0 2 * * 1-5",
    { year: 2026, month: 8, day: 14, hour: 2, minute: 1 },
    { year: 2026, month: 8, day: 17, hour: 2, minute: 0 },
  )
  expect_next(
    "15 6 1,15 * *",
    { year: 2026, month: 1, day: 15, hour: 6, minute: 16 },
    { year: 2026, month: 2, day: 1, hour: 6, minute: 15 },
  )
  expect_next(
    "*/15 9-17 * * 1-5",
    { year: 2026, month: 8, day: 14, hour: 17, minute: 59 },
    { year: 2026, month: 8, day: 17, hour: 9, minute: 0 },
  )
  expect_next(
    "0 */6 * * *",
    { year: 2026, month: 8, day: 10, hour: 11, minute: 0 },
    { year: 2026, month: 8, day: 10, hour: 12, minute: 0 },
  )
  expect_next(
    "0 0 * * 0",
    { year: 2026, month: 8, day: 15, hour: 0, minute: 1 },
    { year: 2026, month: 8, day: 16, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 * * 7",
    { year: 2026, month: 8, day: 16, hour: 0, minute: 1 },
    { year: 2026, month: 8, day: 23, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 1 * *",
    { year: 2026, month: 1, day: 2, hour: 0, minute: 0 },
    { year: 2026, month: 2, day: 1, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 1 1 *",
    { year: 2025, month: 12, day: 31, hour: 23, minute: 59 },
    { year: 2026, month: 1, day: 1, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 * 4,6,9,11 *",
    { year: 2026, month: 4, day: 30, hour: 0, minute: 1 },
    { year: 2026, month: 6, day: 1, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 15 6 *",
    { year: 2026, month: 6, day: 15, hour: 0, minute: 0 },
    { year: 2027, month: 6, day: 15, hour: 0, minute: 0 },
  )
  expect_next(
    "5 4 1-7 * 1",
    { year: 2026, month: 8, day: 10, hour: 4, minute: 6 },
    { year: 2026, month: 8, day: 17, hour: 4, minute: 5 },
  )

  // Month ends and calendar boundaries.
  expect_next(
    "0 0 L * *",
    { year: 2024, month: 2, day: 1, hour: 0, minute: 0 },
    { year: 2024, month: 2, day: 29, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 L * *",
    { year: 2024, month: 2, day: 29, hour: 0, minute: 0 },
    { year: 2024, month: 3, day: 31, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 L * *",
    { year: 2026, month: 4, day: 1, hour: 0, minute: 0 },
    { year: 2026, month: 4, day: 30, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 L 2 *",
    { year: 2025, month: 1, day: 1, hour: 0, minute: 0 },
    { year: 2025, month: 2, day: 28, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 29 2 *",
    { year: 2023, month: 3, day: 1, hour: 0, minute: 0 },
    { year: 2024, month: 2, day: 29, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 30 * *",
    { year: 2026, month: 1, day: 31, hour: 0, minute: 0 },
    { year: 2026, month: 3, day: 30, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 31 * *",
    { year: 2026, month: 4, day: 30, hour: 0, minute: 0 },
    { year: 2026, month: 5, day: 31, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 31 1,3,5,7,8,10,12 *",
    { year: 2026, month: 1, day: 31, hour: 0, minute: 0 },
    { year: 2026, month: 3, day: 31, hour: 0, minute: 0 },
  )

  // Macro aliases and question-mark wildcards.
  expect_next(
    "@hourly",
    { year: 2026, month: 8, day: 10, hour: 23, minute: 59 },
    { year: 2026, month: 8, day: 11, hour: 0, minute: 0 },
  )
  expect_next(
    "@monthly",
    { year: 2026, month: 6, day: 1, hour: 0, minute: 0 },
    { year: 2026, month: 7, day: 1, hour: 0, minute: 0 },
  )
  expect_next(
    "0 0 ? * 1-5",
    { year: 2026, month: 8, day: 14, hour: 0, minute: 1 },
    { year: 2026, month: 8, day: 17, hour: 0, minute: 0 },
  )
}

///|
test "calendar and matcher boundary corpus" {
  assert_eq(@cron.is_leap_year(2000), true)
  assert_eq(@cron.is_leap_year(1900), false)
  assert_eq(@cron.is_leap_year(2024), true)
  assert_eq(@cron.is_leap_year(2026), false)
  assert_eq(@cron.days_in_month(2024, 2), 29)
  assert_eq(@cron.days_in_month(2026, 2), 28)
  assert_eq(@cron.days_in_month(2026, 4), 30)
  assert_eq(@cron.day_of_week(2026, 8, 10), 1)

  let weekday = match @cron.parse("0 9 15 * 1") {
    Ok(value) => value
    Err(_) => panic()
  }
  assert_eq(weekday.matches(2026, 0, 9, 15, 6, 2), true)
  assert_eq(weekday.matches(2026, 0, 9, 8, 6, 1), true)
  assert_eq(weekday.matches(2026, 0, 9, 8, 6, 2), false)

  let sunday = match @cron.parse("0 0 * * 0") {
    Ok(value) => value
    Err(_) => panic()
  }
  assert_eq(sunday.matches(2026, 0, 0, 16, 8, 0), true)
  assert_eq(sunday.matches(2026, 0, 0, 16, 8, 7), true)
  assert_eq(sunday.matches(2026, 0, 0, 17, 8, 1), false)
  assert_eq(sunday.matches(2026, 61, 0, 16, 8, 0), false)
}

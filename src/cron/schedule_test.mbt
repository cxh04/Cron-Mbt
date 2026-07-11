///|
test "calculate next execution time correctly" {
  let cron = match parse("15 10 * * *") {
    Ok(c) => c
    Err(_) => panic()
  }
  let current : DateTime = { year: 2026, month: 6, day: 10, hour: 9, minute: 0 }
  let next = match cron.next_time(current) {
    Ok(dt) => dt
    Err(_) => panic()
  }
  assert_eq(next.hour, 10)
  assert_eq(next.minute, 15)
  assert_eq(next.day, 10)
}

///|
test "next time wraps around day" {
  let cron = match parse("0 1 * * *") {
    Ok(c) => c
    Err(_) => panic()
  }
  let current : DateTime = { year: 2026, month: 6, day: 10, hour: 2, minute: 0 }
  let next = match cron.next_time(current) {
    Ok(dt) => dt
    Err(_) => panic()
  }
  assert_eq(next.hour, 1)
  assert_eq(next.minute, 0)
  assert_eq(next.day, 11)
}

///|
test "next time for last day of month" {
  let cron = match parse("0 0 L * *") {
    Ok(c) => c
    Err(_) => panic()
  }
  // From Jan 15 to Jan 31
  let next1 = match
    cron.next_time({ year: 2026, month: 1, day: 15, hour: 0, minute: 0 }) {
    Ok(dt) => dt
    Err(_) => panic()
  }
  assert_eq(next1.day, 31)

  // From Jan 31 to Feb 28
  let next2 = match
    cron.next_time({ year: 2026, month: 1, day: 31, hour: 0, minute: 0 }) {
    Ok(dt) => dt
    Err(_) => panic()
  }
  assert_eq(next2.month, 2)
  assert_eq(next2.day, 28)
}

///|
test "next time respects day-of-week constraints" {
  let cron = match parse("30 9 * * 1") {
    Ok(c) => c
    Err(_) => panic()
  }
  let next = match
    cron.next_time({ year: 2026, month: 6, day: 9, hour: 10, minute: 0 }) {
    Ok(dt) => dt
    Err(_) => panic()
  }
  assert_eq(next.year, 2026)
  assert_eq(next.month, 6)
  assert_eq(next.day, 15)
  assert_eq(next.hour, 9)
  assert_eq(next.minute, 30)
}

///|
test "next time supports question-mark day wildcard semantics" {
  let cron = match parse("0 8 ? * 1-5") {
    Ok(c) => c
    Err(_) => panic()
  }
  let next = match
    cron.next_time({ year: 2026, month: 6, day: 12, hour: 8, minute: 0 }) {
    Ok(dt) => dt
    Err(_) => panic()
  }
  assert_eq(next.year, 2026)
  assert_eq(next.month, 6)
  assert_eq(next.day, 15)
  assert_eq(next.hour, 8)
  assert_eq(next.minute, 0)
}

///|
test "matches correctly" {
  let expr = match parse("15 12 * * *") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.matches(2026, 15, 12, 10, 6, 3), true)
  assert_eq(expr.matches(2026, 16, 12, 10, 6, 3), false)
}

///|
test "matches last day of month" {
  let expr = match parse("0 0 L * *") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.matches(2026, 0, 0, 31, 1, 3), true) // Jan 31
  assert_eq(expr.matches(2026, 0, 0, 30, 1, 3), false) // Jan 30
  assert_eq(expr.matches(2026, 0, 0, 28, 2, 3), true) // Feb 28 (2026 not leap)
  assert_eq(expr.matches(2024, 0, 0, 29, 2, 3), true) // Feb 29 (2024 leap)
  assert_eq(expr.matches(2024, 0, 0, 28, 2, 3), false) // Feb 28 (2024 leap)
}

///|
test "matches respects cron day-of-month or day-of-week semantics" {
  let expr = match parse("0 9 15 * 1") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.matches(2026, 0, 9, 15, 6, 2), true)
  assert_eq(expr.matches(2026, 0, 9, 8, 6, 1), true)
  assert_eq(expr.matches(2026, 0, 9, 8, 6, 2), false)
}

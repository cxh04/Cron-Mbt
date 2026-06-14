test "matches correctly" {
  let expr = match parse("15 12 * * *") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.matches(15, 12, 10, 6, 3), true)
  assert_eq(expr.matches(16, 12, 10, 6, 3), false)
}

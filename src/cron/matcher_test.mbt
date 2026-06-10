
test "matches correct time" {
  let expr = parse("0 12 * * 1").unwrap()
  assert_true!(expr.matches(0, 12, 15, 6, 1))
  assert_false!(expr.matches(1, 12, 15, 6, 1))
}


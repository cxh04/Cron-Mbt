test "parser handles valid expressions" {
  let expr = match parse("*/5 10-12 * * 1,2") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.minutes.length(), 12)
}

test "parser catches invalid expressions" {
  match parse("*/5 10-12 * *") {
    Ok(_) => panic()
    Err(_) => ()
  }
  
  match parse("*/5 10-12 * * 1,2 *") {
    Ok(_) => panic()
    Err(_) => ()
  }
}

test "parser handles L character for last day of month" {
  let expr = match parse("0 0 L * *") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.has_last_day_of_month, true)
}


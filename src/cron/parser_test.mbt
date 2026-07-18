///|
test "parser handles valid expressions" {
  let expr = match parse("*/5 10-12 * * 1,2") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.minutes.length(), 12)
}

///|
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

///|
test "parser handles L character for last day of month" {
  let expr = match parse("0 0 L * *") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.has_last_day_of_month, true)
}

///|
test "parser accepts question mark wildcard in day fields" {
  let expr = match parse("0 9 ? * 1-5") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.day_of_month_wildcard, true)
  assert_eq(expr.day_of_week_wildcard, false)
}

///|
test "parser normalizes sunday value 7 to 0" {
  let expr = match parse("0 0 * * 0,7") {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(expr.days_of_week.length(), 1)
  assert_eq(expr.days_of_week[0], 0)
}

///|
fn assert_parse_error(raw : String) -> Unit {
  match parse(raw) {
    Ok(_) => panic()
    Err(_) => ()
  }
}

///|
test "parser rejects L outside day of month field" {
  assert_parse_error("L 0 * * *")
  assert_parse_error("0 L * * *")
  assert_parse_error("0 0 * L *")
  assert_parse_error("0 0 * * L")
}

///|
test "parser rejects invalid L step usage" {
  assert_parse_error("0 0 L/2 * *")
}

///|
test "parser returns errors for malformed cron expressions" {
  assert_parse_error("0 0 32 * *")
  assert_parse_error("0 0 * 13 *")
  assert_parse_error("0 0 * * 8")
  assert_parse_error("*/0 * * * *")
  assert_parse_error("0 0 * * 1-0")
  assert_parse_error("0 0 * * MON")
}

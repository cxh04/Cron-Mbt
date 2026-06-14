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

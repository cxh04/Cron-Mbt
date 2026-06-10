
test "parse valid cron" {
  let expr = "0 12 * * 1,2,3"
  let res = parse(expr)
  match res {
    Ok(_) => ()
    Err(_) => fail!("should parse successfully")
  }
}

test "parse invalid cron length" {
  let expr = "0 12 * * 1,2,3 *"
  let res = parse(expr)
  match res {
    Ok(_) => fail!("should fail with 6 fields")
    Err(_) => ()
  }
}


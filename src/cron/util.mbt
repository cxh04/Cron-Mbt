
fn parse_int(s : String) -> Result[Int, CronError] {
  try {
    let val = @strconv.parse_int!(s)
    Ok(val)
  } catch {
    _ => Err(InvalidFormat("Invalid integer: " + s))
  }
}


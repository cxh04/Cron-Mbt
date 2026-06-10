
fn parse_int(s : String) -> Result[Int, CronError] {
  try {
    let val = @strconv.parse_int!(s)
    Ok(val)
  } catch {
    _ => Err(InvalidFormat("Invalid integer: " + s))
  }
}

fn parse_field(field : String, min : Int, max : Int) -> Result[Array[Int], CronError] {
  if field == "*" {
    let result = []
    for i = min; i <= max; i = i + 1 {
      result.push(i)
    }
    return Ok(result)
  }
  return Err(InvalidFormat("Unsupported syntax"))
}


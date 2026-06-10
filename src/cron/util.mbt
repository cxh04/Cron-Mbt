
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
  
  if field.contains(",") {
    let parts = field.split(",").collect()
    let result = []
    for p in parts {
       match parse_int(p) {
         Ok(val) => {
           if val >= min && val <= max {
             result.push(val)
           } else {
             return Err(OutOfBounds("Value out of bounds"))
           }
         }
         Err(e) => return Err(e)
       }
    }
    return Ok(result)
  }

  let val_res = parse_int(field)
  match val_res {
    Ok(val) => {
      if val < min || val > max {
        return Err(OutOfBounds("Value out of bounds"))
      }
      return Ok([val])
    }
    Err(_) => return Err(InvalidFormat("Unsupported syntax"))
  }
}


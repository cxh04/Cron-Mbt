///|
pub fn CronExpr::matches_datetime(self : CronExpr, dt : DateTime) -> Bool {
  match dt.validate() {
    Err(_) => false
    Ok(_) =>
      self.matches(
        dt.year,
        dt.minute,
        dt.hour,
        dt.day,
        dt.month,
        day_of_week(dt.year, dt.month, dt.day),
      )
  }
}

///|
pub fn CronExpr::next_times(
  self : CronExpr,
  current : DateTime,
  count : Int,
) -> Result[Array[DateTime], CronError] {
  if count < 0 {
    return Err(InvalidFormat("count cannot be negative"))
  }
  match current.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let result = []
  let mut cursor = current
  for _ in 0..<count {
    let next = match self.next_time(cursor) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    result.push(next)
    cursor = next
  }
  Ok(result)
}

///|
pub fn CronExpr::occurrences_between(
  self : CronExpr,
  start : DateTime,
  end : DateTime,
  limit : Int,
) -> Result[Array[DateTime], CronError] {
  if limit < 0 {
    return Err(InvalidFormat("limit cannot be negative"))
  }
  match start.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  match end.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  if !start.is_before(end) {
    return Err(InvalidFormat("end must be after start"))
  }
  let result = []
  let mut cursor = start
  let mut attempts = 0
  while result.length() < limit && attempts < 200000 {
    let next = match self.next_time(cursor) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    if next.is_after(end) {
      break
    }
    result.push(next)
    cursor = next
    attempts += 1
  }
  if attempts >= 200000 && result.length() < limit {
    return Err(InvalidFormat("occurrence search exceeded safety limit"))
  }
  Ok(result)
}

///|
pub fn CronExpr::matches_all(
  self : CronExpr,
  values : Array[DateTime],
) -> Array[Bool] {
  values.map(fn(value) { self.matches_datetime(value) })
}

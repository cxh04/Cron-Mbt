///|
pub(all) struct ScheduleEntry {
  name : String
  expression : CronExpr
}

///|
pub(all) struct ScheduleConflict {
  first : String
  second : String
  at : DateTime
}

///|
pub fn make_schedule_entry(
  name : String,
  expression : String,
) -> Result[ScheduleEntry, CronError] {
  if name.trim().is_empty() {
    return Err(InvalidFormat("schedule name cannot be empty"))
  }
  let parsed = match parse(expression) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok({ name, expression: parsed })
}

///|
pub fn find_schedule_conflicts(
  entries : Array[ScheduleEntry],
  start : DateTime,
  horizon_minutes : Int,
) -> Result[Array[ScheduleConflict], CronError] {
  if horizon_minutes < 0 || horizon_minutes > 200000 {
    return Err(InvalidFormat("horizon must be between 0 and 200000 minutes"))
  }
  match start.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let result = []
  for i in 0..<entries.length() {
    for j = i + 1; j < entries.length(); j = j + 1 {
      let mut cursor = start
      let mut found = false
      for _ in 0..<horizon_minutes {
        if !found &&
          entries[i].expression.matches_datetime(cursor) &&
          entries[j].expression.matches_datetime(cursor) {
          result.push({
            first: entries[i].name,
            second: entries[j].name,
            at: cursor,
          })
          found = true
        }
        cursor = cursor.add_minutes(1).unwrap()
      }
    }
  }
  Ok(result)
}

///|
pub fn next_schedule_events(
  entries : Array[ScheduleEntry],
  current : DateTime,
  limit : Int,
) -> Result[Array[(String, DateTime)], CronError] {
  if limit < 0 {
    return Err(InvalidFormat("limit cannot be negative"))
  }
  match current.validate() {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let events = []
  for entry in entries {
    let next = match entry.expression.next_time(current) {
      Ok(value) => value
      Err(err) => return Err(err)
    }
    events.push((entry.name, next))
  }
  events.sort_by(fn(a, b) {
    let order = a.1.compare(b.1)
    if order != 0 {
      order
    } else if a.0 == b.0 {
      0
    } else if a.0 < b.0 {
      -1
    } else {
      1
    }
  })
  let bounded = []
  for i, event in events {
    if i < limit {
      bounded.push(event)
    }
  }
  Ok(bounded)
}

///|
pub(all) struct SchedulePlan {
  entries : Array[ScheduleEntry]
}

///|
pub fn SchedulePlan::new(
  entries : Array[ScheduleEntry],
) -> Result[SchedulePlan, CronError] {
  let names = []
  for entry in entries {
    if entry.name.trim().is_empty() {
      return Err(InvalidFormat("schedule names cannot be empty"))
    }
    if names.contains(entry.name) {
      return Err(InvalidFormat("schedule names must be unique"))
    }
    names.push(entry.name)
  }
  Ok({ entries, })
}

///|
pub fn SchedulePlan::entry_count(self : SchedulePlan) -> Int {
  self.entries.length()
}

///|
pub fn SchedulePlan::entries(self : SchedulePlan) -> Array[ScheduleEntry] {
  self.entries.copy()
}

///|
pub fn SchedulePlan::next_events(
  self : SchedulePlan,
  current : DateTime,
  limit : Int,
) -> Result[Array[(String, DateTime)], CronError] {
  next_schedule_events(self.entries, current, limit)
}

///|
pub fn SchedulePlan::conflicts(
  self : SchedulePlan,
  start : DateTime,
  horizon_minutes : Int,
) -> Result[Array[ScheduleConflict], CronError] {
  find_schedule_conflicts(self.entries, start, horizon_minutes)
}

///|
pub fn SchedulePlan::summary(
  self : SchedulePlan,
  current : DateTime,
) -> Result[String, CronError] {
  let summaries = match summarize_schedule(self.entries, current) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  Ok(render_schedule_summary(summaries))
}

///|
pub fn SchedulePlan::business_events(
  self : SchedulePlan,
  current : DateTime,
  calendar : BusinessCalendar,
  limit : Int,
) -> Result[Array[(String, DateTime)], CronError] {
  let result = []
  for entry in self.entries {
    let values = match
      entry.expression.next_business_times(current, calendar, limit) {
      Ok(events) => events
      Err(err) => return Err(err)
    }
    for value in values {
      result.push((entry.name, value))
    }
  }
  result.sort_by(fn(a, b) {
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
  if result.length() > limit {
    let bounded = []
    for i, event in result {
      if i < limit {
        bounded.push(event)
      }
    }
    Ok(bounded)
  } else {
    Ok(result)
  }
}

///|
pub fn schedule_plan_from_expressions(
  values : Array[(String, String)],
) -> Result[SchedulePlan, CronError] {
  let entries = []
  for value in values {
    let entry = match make_schedule_entry(value.0, value.1) {
      Ok(result) => result
      Err(err) => return Err(err)
    }
    entries.push(entry)
  }
  SchedulePlan::new(entries)
}

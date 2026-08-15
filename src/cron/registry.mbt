///|
pub(all) struct CronRegistry {
  entries : Array[ScheduleEntry]
}

///|
pub fn CronRegistry::new() -> CronRegistry {
  { entries: [] }
}

///|
pub fn CronRegistry::register(
  self : CronRegistry,
  name : String,
  expression : String,
) -> Result[Unit, CronError] {
  let entry = match make_schedule_entry(name, expression) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  for existing in self.entries {
    if existing.name == entry.name {
      return Err(InvalidFormat("registry names must be unique"))
    }
  }
  self.entries.push(entry)
  Ok(())
}

///|
pub fn CronRegistry::upsert(
  self : CronRegistry,
  name : String,
  expression : String,
) -> Result[Unit, CronError] {
  let parsed = match parse(expression) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  for i, existing in self.entries {
    if existing.name == name {
      self.entries[i] = { name, expression: parsed }
      return Ok(())
    }
  }
  self.entries.push({ name, expression: parsed })
  Ok(())
}

///|
pub fn CronRegistry::unregister(self : CronRegistry, name : String) -> Bool {
  for i, entry in self.entries {
    if entry.name == name {
      let _ = self.entries.remove(i)
      return true
    }
  }
  false
}

///|
pub fn CronRegistry::contains(self : CronRegistry, name : String) -> Bool {
  for entry in self.entries {
    if entry.name == name {
      return true
    }
  }
  false
}

///|
pub fn CronRegistry::get(self : CronRegistry, name : String) -> CronExpr? {
  for entry in self.entries {
    if entry.name == name {
      return Some(entry.expression)
    }
  }
  None
}

///|
pub fn CronRegistry::names(self : CronRegistry) -> Array[String] {
  self.entries.map(fn(entry) { entry.name })
}

///|
pub fn CronRegistry::size(self : CronRegistry) -> Int {
  self.entries.length()
}

///|
pub fn CronRegistry::plan(
  self : CronRegistry,
) -> Result[SchedulePlan, CronError] {
  SchedulePlan::new(self.entries)
}

///|
pub fn CronRegistry::next_events(
  self : CronRegistry,
  current : DateTime,
  limit : Int,
) -> Result[Array[(String, DateTime)], CronError] {
  next_schedule_events(self.entries, current, limit)
}

///|
pub fn CronRegistry::conflicts(
  self : CronRegistry,
  start : DateTime,
  horizon_minutes : Int,
) -> Result[Array[ScheduleConflict], CronError] {
  find_schedule_conflicts(self.entries, start, horizon_minutes)
}

///|
pub fn CronRegistry::canonical_lines(self : CronRegistry) -> Array[String] {
  self.entries.map(fn(entry) { "\{entry.name}=\{entry.expression.canonical()}" })
}

///|
pub fn CronRegistry::report(self : CronRegistry) -> String {
  self.entries
  .map(fn(entry) { "\{entry.name}: \{entry.expression.risk_report()}" })
  .join("\n")
}

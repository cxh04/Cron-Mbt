///|
/// A priority routing table for multi-owner schedule services.
pub(all) struct RoutingRule {
  name : String
  expression : CronExpr
  owner : String
  priority : Int
}

///|
pub fn RoutingRule::new(
  name : String,
  raw_expression : String,
  owner : String,
  priority : Int,
) -> Result[RoutingRule, CronError] {
  if name.trim().is_empty() || owner.trim().is_empty() {
    return Err(InvalidFormat("routing name and owner cannot be empty"))
  }
  if priority < 0 {
    return Err(OutOfBounds("routing priority cannot be negative"))
  }
  let expression = match parse(raw_expression) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok({ name, expression, owner, priority })
}

///|
pub(all) struct RoutingTable {
  rules : Array[RoutingRule]
}

///|
pub fn RoutingTable::new() -> RoutingTable {
  { rules: [] }
}

///|
pub fn RoutingTable::add(
  self : RoutingTable,
  rule : RoutingRule,
) -> Result[Unit, CronError] {
  for existing in self.rules {
    if existing.name == rule.name {
      return Err(InvalidFormat("routing rule names must be unique"))
    }
  }
  self.rules.push(rule)
  self.rules.sort_by(fn(a, b) { b.priority - a.priority })
  Ok(())
}

///|
pub fn RoutingTable::remove(self : RoutingTable, name : String) -> Bool {
  for index, rule in self.rules {
    if rule.name == name {
      let _ = self.rules.remove(index)
      return true
    }
  }
  false
}

///|
pub fn RoutingTable::rule_count(self : RoutingTable) -> Int {
  self.rules.length()
}

///|
pub fn RoutingTable::route(
  self : RoutingTable,
  value : DateTime,
) -> Result[String, CronError] {
  for rule in self.rules {
    if rule.expression.matches_datetime(value) {
      return Ok(rule.owner)
    }
  }
  Err(InvalidFormat("no routing rule matched datetime"))
}

///|
pub fn RoutingTable::route_all(
  self : RoutingTable,
  values : Array[DateTime],
) -> Array[(DateTime, String)] {
  let result : Array[(DateTime, String)] = []
  for value in values {
    match self.route(value) {
      Ok(owner) => result.push((value, owner))
      Err(_) => ()
    }
  }
  result
}

///|
pub fn RoutingTable::render(self : RoutingTable) -> String {
  self.rules
  .map(fn(rule) {
    "\{rule.name}=\{rule.owner}@\{rule.priority}:\{rule.expression.canonical()}"
  })
  .join("\n")
}

///|
pub fn RoutingTable::owners(self : RoutingTable) -> Array[String] {
  let result : Array[String] = []
  for rule in self.rules {
    if !result.contains(rule.owner) {
      result.push(rule.owner)
    }
  }
  result
}

///|
pub fn RoutingTable::validate(self : RoutingTable) -> Bool {
  for rule in self.rules {
    if rule.expression.minutes.is_empty() || rule.expression.hours.is_empty() {
      return false
    }
  }
  true
}

///|
pub fn RoutingTable::matching_rules(
  self : RoutingTable,
  value : DateTime,
) -> Array[String] {
  let result : Array[String] = []
  for rule in self.rules {
    if rule.expression.matches_datetime(value) {
      result.push(rule.name)
    }
  }
  result
}

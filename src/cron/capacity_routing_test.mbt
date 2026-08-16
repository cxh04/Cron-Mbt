///|
test "capacity analysis exposes hourly and weekly load" {
  let expr = parse("*/15 8-9 * * 1-5").unwrap()
  let daily = expr.daily_capacity()
  assert_eq(daily[8], 4)
  assert_eq(daily[9], 4)
  assert_eq(daily[0], 0)
  let weekly = expr.weekly_capacity_profile()
  assert_eq(weekly[1], 8)
  assert_eq(weekly[0], 0)
  assert_true(expr.capacity_report().contains("daily-total=8"))
}

///|
test "capacity policy detects bounded overloads" {
  let expr = parse("* * * * *").unwrap()
  let policy = CapacityPolicy::new(100, 5000).unwrap()
  assert_true(expr.exceeds_capacity(policy))
  let daily = parse("0 9 * * *").unwrap()
  assert_true(!daily.exceeds_capacity(policy))
  assert_true(CapacityPolicy::new(0, 1) is Err(_))
}

///|
test "routing table selects matching owners by priority" {
  let table = RoutingTable::new()
  table
  .add(RoutingRule::new("business", "0 9 * * 1-5", "ops", 10).unwrap())
  .unwrap()
  table
  .add(RoutingRule::new("all", "* * * * *", "fallback", 1).unwrap())
  .unwrap()
  let monday : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  let sunday : DateTime = { year: 2026, month: 8, day: 9, hour: 9, minute: 0 }
  assert_eq(table.route(monday).unwrap(), "ops")
  assert_eq(table.route(sunday).unwrap(), "fallback")
  assert_eq(table.rule_count(), 2)
  assert_true(table.render().contains("business"))
}

///|
test "routing table handles unmatched and batch routing" {
  let table = RoutingTable::new()
  table
  .add(RoutingRule::new("monthly", "0 0 1 * *", "finance", 5).unwrap())
  .unwrap()
  let values : Array[DateTime] = [
    { year: 2026, month: 8, day: 1, hour: 0, minute: 0 },
    { year: 2026, month: 8, day: 2, hour: 0, minute: 0 },
  ]
  assert_true(table.route(values[1]) is Err(_))
  assert_eq(table.route_all(values).length(), 1)
  assert_true(table.remove("monthly"))
  assert_true(!table.remove("monthly"))
}

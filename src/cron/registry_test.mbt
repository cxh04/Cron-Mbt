///|
test "registry supports registration, lookup, update, and removal" {
  let registry = CronRegistry::new()
  assert_true(registry.register("billing", "0 9 * * *") is Ok(_))
  assert_true(registry.register("billing", "0 10 * * *") is Err(_))
  assert_true(registry.contains("billing"))
  assert_eq(registry.get("billing").unwrap().canonical(), "0 9 * * *")
  assert_true(registry.upsert("billing", "0 10 * * *") is Ok(_))
  assert_eq(registry.get("billing").unwrap().canonical(), "0 10 * * *")
  assert_true(registry.unregister("billing"))
  assert_true(!registry.contains("billing"))
}

///|
test "registry produces canonical reports and delegates planning" {
  let registry = CronRegistry::new()
  let _ = registry.register("hourly", "0 * * * *")
  let _ = registry.register("backup", "0 9 * * *")
  assert_eq(registry.size(), 2)
  assert_eq(registry.names()[0], "hourly")
  assert_true(registry.canonical_lines()[1].contains("backup=0 9 * * *"))
  assert_true(registry.report().contains("backup"))
  let plan = registry.plan().unwrap()
  assert_eq(plan.entry_count(), 2)
}

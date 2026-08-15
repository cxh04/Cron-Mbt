///|
test "scheduler produces owner-aware runbook entries" {
  let scheduler = JobScheduler::new()
  let daily = JobDefinition::create("daily", "0 9 * * *", "ops").unwrap()
  let hourly = JobDefinition::create("hourly", "0 * * * *", "data").unwrap()
  scheduler.add(daily).unwrap()
  scheduler.add(hourly).unwrap()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 30 }
  let runs = scheduler.runs_for_owner(now, "ops", 4).unwrap()
  assert_eq(runs.length(), 1)
  assert_eq(runs[0].job_name(), "daily")
  assert_eq(scheduler.paused_count(), 0)
  assert_eq(
    scheduler.owner_summary("data", now).unwrap(),
    "hourly: 2026-08-10 09:00",
  )
}

///|
test "scheduler supports retry plans and paused jobs" {
  let scheduler = JobScheduler::new()
  let job = JobDefinition::create("backup", "0 2 * * *", "infra")
    .unwrap()
    .with_retry(30)
    .unwrap()
  scheduler.add(job).unwrap()
  scheduler
  .add(JobDefinition::create("paused", "0 1 * * *", "infra").unwrap().pause())
  .unwrap()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  let runs = scheduler.next_runs_with_retries(now, 4).unwrap()
  assert_eq(runs.length(), 1)
  assert_true(runs[0].retry_at is Some(_))
  assert_eq(scheduler.paused_count(), 1)
  assert_eq(scheduler.enabled_count(), 1)
}

///|
test "scheduler rejects invalid owner queries" {
  let scheduler = JobScheduler::new()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 0, minute: 0 }
  assert_true(scheduler.runs_for_owner(now, "missing", 1).unwrap().is_empty())
  assert_true(scheduler.owner_summary("missing", now).unwrap() == "none")
  assert_true(scheduler.next_runs_with_retries(now, -1) is Err(_))
}

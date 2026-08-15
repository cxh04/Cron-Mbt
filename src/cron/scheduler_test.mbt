///|
test "job scheduler creates paused and retryable jobs" {
  let job = JobDefinition::create("billing", "0 9 * * 1-5", "finance").unwrap()
  let retryable = job.with_retry(15).unwrap()
  assert_eq(retryable.retry_minutes, 15)
  assert_true(
    retryable
    .pause()
    .next({ year: 2026, month: 8, day: 10, hour: 8, minute: 0 })
    is Err(_),
  )
  assert_true(
    retryable
    .enable()
    .next({ year: 2026, month: 8, day: 10, hour: 8, minute: 0 })
    is Ok(_),
  )
}

///|
test "job scheduler orders runs and reports retry times" {
  let scheduler = JobScheduler::new()
  let _ = scheduler.add(
    JobDefinition::create("billing", "0 9 * * *", "finance").unwrap(),
  )
  let _ = scheduler.add(
    JobDefinition::create("heartbeat", "30 * * * *", "platform").unwrap(),
  )
  assert_eq(scheduler.job_count(), 2)
  let current : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let runs = scheduler.next_runs(current, 2).unwrap()
  assert_eq(runs[0].job, "heartbeat")
  assert_eq(runs[0].scheduled_at.format(), "2026-08-10 08:30")
  assert_true(scheduler.report(current).unwrap().contains("billing"))
}

///|
test "job scheduler enforces unique names and tracks owners" {
  let scheduler = JobScheduler::new()
  let first = JobDefinition::create("one", "0 0 * * *", "ops").unwrap()
  let second = JobDefinition::create("one", "0 1 * * *", "ops").unwrap()
  assert_true(scheduler.add(first) is Ok(_))
  assert_true(scheduler.add(second) is Err(_))
  assert_eq(scheduler.owners().length(), 1)
  assert_eq(scheduler.owners()[0], "ops")
  assert_true(scheduler.remove("one"))
  assert_eq(scheduler.job_count(), 0)
}

///|
test "orchestration computes bounded retry schedules" {
  let policy = RetryPolicy::new(3, 5, 60).unwrap()
  let delays = policy.delays()
  assert_eq(delays.length(), 3)
  assert_eq(delays[0], 5)
  assert_eq(delays[2], 20)
  let job = JobDefinition::create("sync", "0 9 * * *", "ops").unwrap()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 9, minute: 0 }
  assert_eq(job.retry_schedule(now, policy).unwrap().length(), 3)
  assert_true(RetryPolicy::new(0, 5, 60) is Err(_))
}

///|
test "orchestration previews workflow runs within a horizon" {
  let workflow = Workflow::new("deploy")
  workflow
  .add_stage(WorkflowStage::new("build", "0 9 * * *", 1).unwrap())
  .unwrap()
  workflow
  .add_stage(WorkflowStage::new("release", "30 9 * * *", 2).unwrap())
  .unwrap()
  let now : DateTime = { year: 2026, month: 8, day: 10, hour: 8, minute: 0 }
  let runs = workflow.next_runs(now, 120).unwrap()
  assert_eq(runs.length(), 2)
  assert_eq(runs[1].scheduled_at.format(), "2026-08-10 09:30")
}

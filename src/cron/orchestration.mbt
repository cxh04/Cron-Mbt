///|
/// Retry and orchestration policies for production job execution.
pub(all) struct RetryPolicy {
  attempts : Int
  initial_delay : Int
  maximum_delay : Int
}

///|
pub fn RetryPolicy::new(
  attempts : Int,
  initial_delay : Int,
  maximum_delay : Int,
) -> Result[RetryPolicy, CronError] {
  if attempts <= 0 || attempts > 100 {
    return Err(OutOfBounds("retry attempts must be between 1 and 100"))
  }
  if initial_delay <= 0 || maximum_delay < initial_delay {
    return Err(OutOfBounds("retry delays are invalid"))
  }
  Ok({ attempts, initial_delay, maximum_delay })
}

///|
pub fn RetryPolicy::delays(self : RetryPolicy) -> Array[Int] {
  let result : Array[Int] = []
  let mut delay = self.initial_delay
  for _ in 0..<self.attempts {
    result.push(delay)
    if delay <= self.maximum_delay / 2 {
      delay *= 2
    } else {
      delay = self.maximum_delay
    }
  }
  result
}

///|
pub fn RetryPolicy::render(self : RetryPolicy) -> String {
  "attempts=\{self.attempts}; initial=\{self.initial_delay}m; maximum=\{self.maximum_delay}m"
}

///|
pub fn JobDefinition::retry_schedule(
  self : JobDefinition,
  current : DateTime,
  policy : RetryPolicy,
) -> Result[Array[DateTime], CronError] {
  let first = match self.next(current) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  let result : Array[DateTime] = []
  let mut cursor = first
  for delay in policy.delays() {
    cursor = cursor.add_minutes(delay).unwrap()
    result.push(cursor)
  }
  Ok(result)
}

///|
pub fn JobScheduler::retry_runs(
  self : JobScheduler,
  current : DateTime,
  policy : RetryPolicy,
) -> Result[Array[JobRun], CronError] {
  let result : Array[JobRun] = []
  for job in self.jobs {
    let retries = match job.retry_schedule(current, policy) {
      Ok(values) => values
      Err(err) => return Err(err)
    }
    for value in retries {
      result.push(JobRun::new(job.job_name(), value, None))
    }
  }
  result.sort_by(fn(a, b) { a.scheduled_at.compare(b.scheduled_at) })
  Ok(result)
}

///|
pub fn Workflow::next_runs(
  self : Workflow,
  current : DateTime,
  horizon_minutes : Int,
) -> Result[Array[WorkflowRun], CronError] {
  if horizon_minutes < 0 {
    return Err(InvalidFormat("workflow horizon cannot be negative"))
  }
  let end = match current.add_minutes(horizon_minutes) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  let result : Array[WorkflowRun] = []
  for stage in self.stages {
    let values = match stage.expression.occurrences_between(current, end, 1) {
      Ok(items) => items
      Err(err) => return Err(err)
    }
    for value in values {
      if stage.enabled {
        result.push({
          stage: stage.stage,
          scheduled_at: value,
          order: stage.order,
        })
      }
    }
  }
  result.sort_by(fn(a, b) { a.scheduled_at.compare(b.scheduled_at) })
  Ok(result)
}

///|
pub fn Workflow::enabled_stage_count(self : Workflow) -> Int {
  let mut count = 0
  for stage in self.stages {
    if stage.enabled {
      count += 1
    }
  }
  count
}

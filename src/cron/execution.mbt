///|
pub fn JobDefinition::job_name(self : JobDefinition) -> String {
  self.name
}

///|
/// Return the next run only when the job belongs to the requested owner.
pub fn JobScheduler::runs_for_owner(
  self : JobScheduler,
  current : DateTime,
  owner : String,
  limit : Int,
) -> Result[Array[JobRun], CronError] {
  if limit < 0 {
    return Err(InvalidFormat("limit cannot be negative"))
  }
  let result : Array[JobRun] = []
  for job in self.jobs {
    if job.owner == owner {
      match job.next(current) {
        Ok(value) => {
          let retry = if job.retry_minutes > 0 {
            Some(value.add_minutes(job.retry_minutes).unwrap())
          } else {
            None
          }
          result.push(JobRun::new(job.name, value, retry))
        }
        Err(_) => ()
      }
    }
  }
  result.sort_by(fn(a, b) { a.scheduled_at.compare(b.scheduled_at) })
  let bounded : Array[JobRun] = []
  for i, value in result {
    if i < limit {
      bounded.push(value)
    }
  }
  Ok(bounded)
}

///|
pub fn JobScheduler::next_runs_with_retries(
  self : JobScheduler,
  current : DateTime,
  limit : Int,
) -> Result[Array[JobRun], CronError] {
  self.next_runs(current, limit)
}

///|
pub fn JobScheduler::paused_count(self : JobScheduler) -> Int {
  let mut count = 0
  for job in self.jobs {
    match job.state {
      Paused => count += 1
      Enabled => ()
    }
  }
  count
}

///|
pub fn JobScheduler::enabled_count(self : JobScheduler) -> Int {
  self.jobs.length() - self.paused_count()
}

///|
pub fn JobRun::job_name(self : JobRun) -> String {
  self.job
}

///|
/// Render a single owner's next run for status pages.
pub fn JobScheduler::owner_summary(
  self : JobScheduler,
  owner : String,
  current : DateTime,
) -> Result[String, CronError] {
  let runs = match self.runs_for_owner(current, owner, 1) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  if runs.is_empty() {
    Ok("none")
  } else {
    Ok("\{runs[0].job_name()}: \{runs[0].scheduled_at.format()}")
  }
}

///|
pub(all) enum JobState {
  Enabled
  Paused
} derive(Debug, Eq)

///|
pub(all) struct JobDefinition {
  name : String
  expression : CronExpr
  state : JobState
  owner : String
  retry_minutes : Int
}

///|
pub fn JobDefinition::create(
  name : String,
  expression : String,
  owner : String,
) -> Result[JobDefinition, CronError] {
  if name.trim().is_empty() {
    return Err(InvalidFormat("job name cannot be empty"))
  }
  if owner.trim().is_empty() {
    return Err(InvalidFormat("job owner cannot be empty"))
  }
  let parsed = match parse(expression) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  Ok({ name, expression: parsed, state: Enabled, owner, retry_minutes: 0 })
}

///|
pub fn JobDefinition::pause(self : JobDefinition) -> JobDefinition {
  { ..self, state: Paused }
}

///|
pub fn JobDefinition::enable(self : JobDefinition) -> JobDefinition {
  { ..self, state: Enabled }
}

///|
pub fn JobDefinition::with_retry(
  self : JobDefinition,
  retry_minutes : Int,
) -> Result[JobDefinition, CronError] {
  if retry_minutes < 0 || retry_minutes > 1440 {
    return Err(OutOfBounds("retry interval must be between 0 and 1440 minutes"))
  }
  Ok({ ..self, retry_minutes, })
}

///|
pub fn JobDefinition::next(
  self : JobDefinition,
  current : DateTime,
) -> Result[DateTime, CronError] {
  match self.state {
    Enabled => self.expression.next_time(current)
    Paused => Err(InvalidFormat("paused job has no next run"))
  }
}

///|
pub(all) struct JobRun {
  job : String
  scheduled_at : DateTime
  retry_at : DateTime?
}

///|
pub fn JobRun::new(
  job : String,
  scheduled_at : DateTime,
  retry_at : DateTime?,
) -> JobRun {
  { job, scheduled_at, retry_at }
}

///|
pub fn JobRun::format(self : JobRun) -> String {
  let retry = match self.retry_at {
    Some(value) => "; retry=\{value.format()}"
    None => "; retry=none"
  }
  "\{self.job}: scheduled=\{self.scheduled_at.format()}\{retry}"
}

///|
pub(all) struct JobScheduler {
  jobs : Array[JobDefinition]
}

///|
pub fn JobScheduler::new() -> JobScheduler {
  { jobs: [] }
}

///|
pub fn JobScheduler::add(
  self : JobScheduler,
  job : JobDefinition,
) -> Result[Unit, CronError] {
  for existing in self.jobs {
    if existing.name == job.name {
      return Err(InvalidFormat("job names must be unique"))
    }
  }
  self.jobs.push(job)
  Ok(())
}

///|
pub fn JobScheduler::remove(self : JobScheduler, name : String) -> Bool {
  for i, job in self.jobs {
    if job.name == name {
      let _ = self.jobs.remove(i)
      return true
    }
  }
  false
}

///|
pub fn JobScheduler::job_count(self : JobScheduler) -> Int {
  self.jobs.length()
}

///|
pub fn JobScheduler::next_runs(
  self : JobScheduler,
  current : DateTime,
  limit : Int,
) -> Result[Array[JobRun], CronError] {
  if limit < 0 {
    return Err(InvalidFormat("limit cannot be negative"))
  }
  let result = []
  for job in self.jobs {
    match job.next(current) {
      Ok(value) => {
        let retry = if job.retry_minutes > 0 {
          Some(value.add_minutes(job.retry_minutes).unwrap())
        } else {
          None
        }
        result.push(JobRun::new(job.name, value, retry))
      }
      Err(err) =>
        match job.state {
          Enabled => return Err(err)
          Paused => ()
        }
    }
  }
  result.sort_by(fn(a, b) { a.scheduled_at.compare(b.scheduled_at) })
  let bounded = []
  for i, value in result {
    if i < limit {
      bounded.push(value)
    }
  }
  Ok(bounded)
}

///|
pub fn JobScheduler::owners(self : JobScheduler) -> Array[String] {
  let result = []
  for job in self.jobs {
    if !result.contains(job.owner) {
      result.push(job.owner)
    }
  }
  result
}

///|
pub fn JobScheduler::report(
  self : JobScheduler,
  current : DateTime,
) -> Result[String, CronError] {
  let runs = match self.next_runs(current, self.jobs.length()) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  Ok(runs.map(fn(run) { run.format() }).join("\n"))
}

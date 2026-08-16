///|
/// Application-facing service facade over the cron registry and scheduler.
pub(all) struct ScheduleService {
  calendar : BusinessCalendar
  jobs : Array[JobDefinition]
}

///|
pub fn ScheduleService::new(calendar : BusinessCalendar) -> ScheduleService {
  { calendar, jobs: [] }
}

///|
pub fn ScheduleService::register(
  self : ScheduleService,
  name : String,
  expression : String,
  owner : String,
) -> Result[Unit, CronError] {
  let job = match JobDefinition::create(name, expression, owner) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  for existing in self.jobs {
    if existing.job_name() == job.job_name() {
      return Err(InvalidFormat("service job names must be unique"))
    }
  }
  self.jobs.push(job)
  Ok(())
}

///|
pub fn ScheduleService::remove(self : ScheduleService, name : String) -> Bool {
  for index, job in self.jobs {
    if job.job_name() == name {
      let _ = self.jobs.remove(index)
      return true
    }
  }
  false
}

///|
pub fn ScheduleService::job_count(self : ScheduleService) -> Int {
  self.jobs.length()
}

///|
/// Return the next run of every enabled service job.
pub fn ScheduleService::preview(
  self : ScheduleService,
  current : DateTime,
  limit : Int,
) -> Result[Array[JobRun], CronError] {
  let scheduler = JobScheduler::new()
  for job in self.jobs {
    scheduler.add(job).unwrap()
  }
  scheduler.next_runs(current, limit)
}

///|
pub fn ScheduleService::business_preview(
  self : ScheduleService,
  current : DateTime,
  count : Int,
) -> Result[Array[DateTime], CronError] {
  if self.jobs.is_empty() {
    return Ok([])
  }
  self.jobs[0].expression.next_business_times(current, self.calendar, count)
}

///|
pub fn ScheduleService::health_report(
  self : ScheduleService,
  current : DateTime,
) -> Result[String, CronError] {
  let runs = match self.preview(current, self.jobs.length()) {
    Ok(values) => values
    Err(err) => return Err(err)
  }
  let enabled = runs.length()
  let jobs = self.jobs.length()
  let owners = self.owners().length()
  Ok("jobs=\{jobs}; enabled-preview=\{enabled}; owners=\{owners}")
}

///|
pub fn ScheduleService::owners(self : ScheduleService) -> Array[String] {
  let result : Array[String] = []
  for job in self.jobs {
    if !result.contains(job.owner) {
      result.push(job.owner)
    }
  }
  result
}

///|
pub fn ScheduleService::validate_all(self : ScheduleService) -> Bool {
  for job in self.jobs {
    if job.expression.minutes.is_empty() || job.expression.hours.is_empty() {
      return false
    }
  }
  true
}

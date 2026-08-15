///|
/// Resource limits used by CLI and service integrations before expanding a schedule.
pub(all) struct SchedulePolicy {
  max_events_per_day : Int
  max_horizon_minutes : Int
}

///|
pub fn SchedulePolicy::new(
  max_events_per_day : Int,
  max_horizon_minutes : Int,
) -> Result[SchedulePolicy, CronError] {
  if max_events_per_day <= 0 || max_events_per_day > 100000 {
    return Err(OutOfBounds("daily event limit must be between 1 and 100000"))
  }
  if max_horizon_minutes <= 0 || max_horizon_minutes > 200000 {
    return Err(OutOfBounds("horizon must be between 1 and 200000 minutes"))
  }
  Ok({ max_events_per_day, max_horizon_minutes })
}

///|
/// Check static daily capacity before running a query.
pub fn CronExpr::check_policy(
  self : CronExpr,
  policy : SchedulePolicy,
) -> Result[Bool, CronError] {
  let daily = self.events_per_day()
  if daily > policy.max_events_per_day {
    return Err(OutOfBounds("schedule exceeds daily event policy"))
  }
  Ok(true)
}

///|
/// Expand occurrences only when both static and dynamic limits are satisfied.
pub fn CronExpr::safe_occurrences_between(
  self : CronExpr,
  start : DateTime,
  end : DateTime,
  policy : SchedulePolicy,
) -> Result[Array[DateTime], CronError] {
  match self.check_policy(policy) {
    Ok(_) => ()
    Err(err) => return Err(err)
  }
  let horizon = match start.minutes_until(end) {
    Ok(value) => value
    Err(err) => return Err(err)
  }
  if horizon > policy.max_horizon_minutes {
    return Err(OutOfBounds("query horizon exceeds schedule policy"))
  }
  self.occurrences_between(start, end, policy.max_events_per_day * 31)
}

///|
pub fn CronExpr::policy_report(
  self : CronExpr,
  policy : SchedulePolicy,
) -> String {
  let daily = self.events_per_day()
  "daily-limit=\{policy.max_events_per_day}; horizon=\{policy.max_horizon_minutes}m; estimated-daily=\{daily}"
}

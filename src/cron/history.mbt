///|
/// Lightweight in-memory execution history for service health dashboards.
pub(all) enum ExecutionStatus {
  Success
  Failure(String)
} derive(Debug, Eq)

///|
pub(all) struct ExecutionRecord {
  scheduled_at : DateTime
  status : ExecutionStatus
}

///|
pub(all) struct ExecutionHistory {
  name : String
  records : Array[ExecutionRecord]
}

///|
pub fn ExecutionHistory::new(name : String) -> ExecutionHistory {
  { name, records: [] }
}

///|
pub fn ExecutionHistory::record_success(
  self : ExecutionHistory,
  at : DateTime,
) -> Unit {
  self.records.push({ scheduled_at: at, status: Success })
}

///|
pub fn ExecutionHistory::record_failure(
  self : ExecutionHistory,
  at : DateTime,
  reason : String,
) -> Unit {
  self.records.push({ scheduled_at: at, status: Failure(reason) })
}

///|
pub fn ExecutionHistory::total_runs(self : ExecutionHistory) -> Int {
  self.records.length()
}

///|
pub fn ExecutionHistory::successful_runs(self : ExecutionHistory) -> Int {
  let mut count = 0
  for record in self.records {
    match record.status {
      Success => count += 1
      Failure(_) => ()
    }
  }
  count
}

///|
pub fn ExecutionHistory::failed_runs(self : ExecutionHistory) -> Int {
  self.total_runs() - self.successful_runs()
}

///|
/// Rounded integer percentage of successful executions.
pub fn ExecutionHistory::success_rate(self : ExecutionHistory) -> Int {
  if self.total_runs() == 0 {
    0
  } else {
    self.successful_runs() * 100 / self.total_runs()
  }
}

///|
pub fn ExecutionHistory::latest(self : ExecutionHistory) -> ExecutionRecord? {
  if self.records.is_empty() {
    None
  } else {
    Some(self.records[self.records.length() - 1])
  }
}

///|
pub fn ExecutionHistory::health_report(self : ExecutionHistory) -> String {
  let runs = self.total_runs()
  let success = self.successful_runs()
  let failed = self.failed_runs()
  let rate = self.success_rate()
  "job=\{self.name}; runs=\{runs}; success=\{success}; failed=\{failed}; success-rate=\{rate}%"
}

///|
/// Keep only the newest records, useful for bounded service memory.
pub fn ExecutionHistory::retain_latest(
  self : ExecutionHistory,
  limit : Int,
) -> Result[Unit, CronError] {
  if limit < 0 {
    return Err(InvalidFormat("history limit cannot be negative"))
  }
  while self.records.length() > limit {
    let _ = self.records.remove(0)
  }
  Ok(())
}

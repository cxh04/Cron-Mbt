///|
/// Runtime metrics for monitoring schedule-backed services.
pub(all) struct ServiceMetrics {
  service : String
  mut requests : Int
  mut successes : Int
  mut failures : Int
  mut total_latency : Int
  mut last_error : String?
}

///|
pub fn ServiceMetrics::new(service : String) -> ServiceMetrics {
  {
    service,
    requests: 0,
    successes: 0,
    failures: 0,
    total_latency: 0,
    last_error: None,
  }
}

///|
pub fn ServiceMetrics::observe_success(
  self : ServiceMetrics,
  latency : Int,
) -> Unit {
  if latency >= 0 {
    self.requests += 1
    self.successes += 1
    self.total_latency += latency
  }
}

///|
pub fn ServiceMetrics::observe_failure(
  self : ServiceMetrics,
  latency : Int,
  reason : String,
) -> Unit {
  if latency >= 0 {
    self.requests += 1
    self.failures += 1
    self.total_latency += latency
    self.last_error = Some(reason)
  }
}

///|
pub fn ServiceMetrics::request_count(self : ServiceMetrics) -> Int {
  self.requests
}

///|
pub fn ServiceMetrics::success_count(self : ServiceMetrics) -> Int {
  self.successes
}

///|
pub fn ServiceMetrics::failure_count(self : ServiceMetrics) -> Int {
  self.failures
}

///|
pub fn ServiceMetrics::average_latency(self : ServiceMetrics) -> Int {
  if self.requests == 0 {
    0
  } else {
    self.total_latency / self.requests
  }
}

///|
pub fn ServiceMetrics::error_rate(self : ServiceMetrics) -> Int {
  if self.requests == 0 {
    0
  } else {
    self.failures * 100 / self.requests
  }
}

///|
pub fn ServiceMetrics::is_healthy(
  self : ServiceMetrics,
  maximum_error_rate : Int,
) -> Bool {
  maximum_error_rate >= 0 && self.error_rate() <= maximum_error_rate
}

///|
pub fn ServiceMetrics::last_error(self : ServiceMetrics) -> String {
  match self.last_error {
    Some(value) => value
    None => "none"
  }
}

///|
pub fn ServiceMetrics::availability(self : ServiceMetrics) -> Int {
  if self.requests == 0 {
    100
  } else {
    100 - self.error_rate()
  }
}

///|
pub fn ServiceMetrics::has_activity(self : ServiceMetrics) -> Bool {
  self.requests > 0
}

///|
pub fn ServiceMetrics::status(
  self : ServiceMetrics,
  maximum_error_rate : Int,
) -> String {
  if !self.has_activity() {
    "idle"
  } else if self.is_healthy(maximum_error_rate) {
    "healthy"
  } else {
    "degraded"
  }
}

///|
pub fn ServiceMetrics::capacity(
  self : ServiceMetrics,
  maximum_requests : Int,
) -> Int {
  if maximum_requests <= 0 {
    0
  } else {
    maximum_requests - self.requests
  }
}

///|
pub fn ServiceMetrics::within_latency(
  self : ServiceMetrics,
  threshold : Int,
) -> Bool {
  threshold >= 0 && self.average_latency() <= threshold
}

///|
pub fn ServiceMetrics::snapshot(self : ServiceMetrics) -> Array[(String, Int)] {
  [
    ("requests", self.requests),
    ("successes", self.successes),
    ("failures", self.failures),
    ("error_rate", self.error_rate()),
    ("availability", self.availability()),
    ("average_latency", self.average_latency()),
  ]
}

///|
pub fn ServiceMetrics::over_latency(
  self : ServiceMetrics,
  threshold : Int,
) -> Bool {
  self.average_latency() > threshold
}

///|
pub fn ServiceMetrics::reset(self : ServiceMetrics) -> Unit {
  self.requests = 0
  self.successes = 0
  self.failures = 0
  self.total_latency = 0
  self.last_error = None
}

///|
pub fn ServiceMetrics::merge(
  self : ServiceMetrics,
  other : ServiceMetrics,
) -> Unit {
  self.requests += other.requests
  self.successes += other.successes
  self.failures += other.failures
  self.total_latency += other.total_latency
  match other.last_error {
    Some(value) => self.last_error = Some(value)
    None => ()
  }
}

///|
pub fn ServiceMetrics::render(self : ServiceMetrics) -> String {
  let error = match self.last_error {
    Some(value) => value
    None => "none"
  }
  "service=\{self.service}; requests=\{self.requests}; success=\{self.successes}; failures=\{self.failures}; error-rate=\{self.error_rate()}%; average-latency=\{self.average_latency()}ms; last-error=\{error}"
}

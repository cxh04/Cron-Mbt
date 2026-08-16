///|
test "service metrics aggregate execution history" {
  let metrics = ServiceMetrics::new("api")
  metrics.observe_success(120)
  metrics.observe_success(80)
  metrics.observe_failure(300, "timeout")
  assert_eq(metrics.request_count(), 3)
  assert_eq(metrics.success_count(), 2)
  assert_eq(metrics.failure_count(), 1)
  assert_eq(metrics.average_latency(), 166)
  assert_true(metrics.render().contains("service=api"))
}

///|
test "service metrics reset and threshold checks" {
  let metrics = ServiceMetrics::new("worker")
  metrics.observe_success(10)
  assert_true(!metrics.over_latency(20))
  assert_true(metrics.over_latency(5))
  metrics.reset()
  assert_eq(metrics.request_count(), 0)
}

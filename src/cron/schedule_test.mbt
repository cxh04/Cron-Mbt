test "calculate next execution time correctly" {
  let cron = parse("15 10 * * *").unwrap()
  let current = { year: 2026, month: 6, day: 10, hour: 9, minute: 0 }
  let next = cron.next_time(current).unwrap()
  assert_eq!(next.hour, 10)
  assert_eq!(next.minute, 15)
  assert_eq!(next.day, 10)
}

test "next time wraps around day" {
  let cron = parse("0 1 * * *").unwrap()
  let current = { year: 2026, month: 6, day: 10, hour: 2, minute: 0 }
  let next = cron.next_time(current).unwrap()
  assert_eq!(next.hour, 1)
  assert_eq!(next.minute, 0)
  assert_eq!(next.day, 11)
}

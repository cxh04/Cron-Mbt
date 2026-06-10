test "macro expands correctly" {
  assert_eq!(expand_macro("@hourly"), "0 * * * *")
  assert_eq!(expand_macro("@daily"), "0 0 * * *")
  assert_eq!(expand_macro("1 2 3 4 5"), "1 2 3 4 5")
}

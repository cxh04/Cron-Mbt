test "white box test for lexer internal state" {
  let lexer = Lexer::new("15 *")
  let t1 = lexer.next_token().unwrap()
  assert_eq!(lexer.pos, 2)
  assert_eq!(t1, Number(15))
}

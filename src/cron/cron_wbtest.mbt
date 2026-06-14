test "lexer test" {
  let lexer = Lexer::new("15 *")
  let t1 = match lexer.next_token() {
    Ok(t) => t
    Err(_) => panic()
  }
  assert_eq(lexer.pos, 2)
  assert_eq(t1, Token::Number(15))
}

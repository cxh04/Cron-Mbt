test "lexer parses numbers and symbols" {
  let lexer = Lexer::new("*/5 10-12 * * 1,2")
  let tokens = lexer.lex_all().unwrap()
  assert_eq!(tokens[0], Asterisk)
  assert_eq!(tokens[1], Slash)
  assert_eq!(tokens[2], Number(5))
  assert_eq!(tokens[3], Number(10))
  assert_eq!(tokens[4], Dash)
  assert_eq!(tokens[5], Number(12))
}

test "lexer handles errors" {
  let lexer = Lexer::new("*/5 abc")
  match lexer.lex_all() {
    Ok(_) => fail!("should fail on abc")
    Err(_) => ()
  }
}

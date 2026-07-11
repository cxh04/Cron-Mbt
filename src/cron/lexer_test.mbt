///|
test "lexer parses numbers and symbols" {
  let lexer = Lexer::new("*/5 10-12 * * 1,2")
  let tokens = match lexer.lex_all() {
    Ok(v) => v
    Err(_) => panic()
  }
  assert_eq(tokens[0], Token::Asterisk)
  assert_eq(tokens[1], Token::Slash)
  assert_eq(tokens[2], Token::Number(5))
  assert_eq(tokens[3], Token::Space) // we added space tokens!
  assert_eq(tokens[4], Token::Number(10))
  assert_eq(tokens[5], Token::Dash)
  assert_eq(tokens[6], Token::Number(12))
}

///|
test "lexer handles errors" {
  let lexer = Lexer::new("*/5 abc")
  match lexer.lex_all() {
    Ok(_) => panic()
    Err(_) => ()
  }
}

///|
test "lexer supports question mark wildcard" {
  let lexer = Lexer::new("?")
  let token = match lexer.next_token() {
    Ok(value) => value
    Err(_) => panic()
  }
  assert_eq(token, Token::Question)
}

pub(all) enum Token {
  Asterisk
  Slash
  Dash
  Comma
  Number(Int)
  Space
  EOF
} derive(Show, Eq)

pub(all) struct Lexer {
  input : String
  mut pos : Int
}

pub fn Lexer::new(input : String) -> Lexer {
  { input, pos: 0 }
}

pub fn Lexer::next_token(self : Lexer) -> Result[Token, CronError] {
  if self.pos >= self.input.length() {
    return Ok(EOF)
  }

  let ch = self.input[self.pos]
  if ch == '*' {
    self.pos += 1
    return Ok(Asterisk)
  } else if ch == '/' {
    self.pos += 1
    return Ok(Slash)
  } else if ch == '-' {
    self.pos += 1
    return Ok(Dash)
  } else if ch == ',' {
    self.pos += 1
    return Ok(Comma)
  } else if ch >= '0' && ch <= '9' {
    let mut num = 0
    while self.pos < self.input.length() {
      let c = self.input[self.pos]
      if c >= '0' && c <= '9' {
        let digit = c.to_int() - '0'.to_int()
        num = num * 10 + digit
        self.pos += 1
      } else {
        break
      }
    }
    return Ok(Number(num))
  } else if ch == ' ' || ch == '\t' {
    while self.pos < self.input.length() && (self.input[self.pos] == ' ' || self.input[self.pos] == '\t') {
      self.pos += 1
    }
    return Ok(Space)
  } else {
    return Err(InvalidFormat("Unexpected character in expression"))
  }
}

pub fn Lexer::peek_token(self : Lexer) -> Result[Token, CronError] {
  let old_pos = self.pos
  let tok = self.next_token()
  self.pos = old_pos
  tok
}

pub fn Lexer::lex_all(self : Lexer) -> Result[Array[Token], CronError] {
  let tokens = []
  while true {
    let tok = match self.next_token() {
      Ok(t) => t
      Err(e) => return Err(e)
    }
    if tok == EOF {
      break
    }
    tokens.push(tok)
  }
  Ok(tokens)
}

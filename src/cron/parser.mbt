fn parse_base(lexer : Lexer) -> Result[AstNode, CronError] {
  let tok = match lexer.next_token() {
    Ok(t) => t
    Err(e) => return Err(e)
  }
  match tok {
    Asterisk => Ok(All(0, 0))
    Number(v) => {
      let peek = match lexer.peek_token() {
        Ok(t) => t
        Err(e) => return Err(e)
      }
      match peek {
        Dash => {
          let _ = lexer.next_token() // consume dash
          let end_tok = match lexer.next_token() {
            Ok(t) => t
            Err(e) => return Err(e)
          }
          match end_tok {
            Number(e) => Ok(Range(v, e))
            _ => Err(InvalidFormat("Expected number after dash"))
          }
        }
        _ => Ok(Value(v))
      }
    }
    _ => Err(InvalidFormat("Expected number or asterisk"))
  }
}

fn parse_part(lexer : Lexer) -> Result[AstNode, CronError] {
  let base = match parse_base(lexer) {
    Ok(b) => b
    Err(e) => return Err(e)
  }
  let peek = match lexer.peek_token() {
    Ok(t) => t
    Err(e) => return Err(e)
  }
  match peek {
    Slash => {
      let _ = lexer.next_token() // consume slash
      let step_tok = match lexer.next_token() {
        Ok(t) => t
        Err(e) => return Err(e)
      }
      match step_tok {
        Number(s) => Ok(Step(base, s))
        _ => Err(InvalidFormat("Expected number after slash"))
      }
    }
    _ => Ok(base)
  }
}

fn parse_field_ast(lexer : Lexer) -> Result[AstNode, CronError] {
  let parts = []
  while true {
    let p = match parse_part(lexer) {
      Ok(x) => x
      Err(e) => return Err(e)
    }
    parts.push(p)
    let peek = match lexer.peek_token() {
      Ok(x) => x
      Err(e) => return Err(e)
    }
    match peek {
      Comma => {
        let _ = lexer.next_token() // consume comma
        continue
      }
      Space | EOF => {
        if peek == Space {
          let _ = lexer.next_token() // consume space
        }
        break
      }
      _ => return Err(InvalidFormat("Unexpected token in field"))
    }
  }
  if parts.length() == 1 {
    Ok(parts[0])
  } else {
    Ok(List(parts))
  }
}

pub fn parse(raw_expr : String) -> Result[CronExpr, CronError] {
  let expr = expand_macro(raw_expr)
  let lexer = Lexer::new(expr)
  
  let minutes_node = match parse_field_ast(lexer) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  let hours_node = match parse_field_ast(lexer) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  let days_of_month_node = match parse_field_ast(lexer) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  let months_node = match parse_field_ast(lexer) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  let days_of_week_node = match parse_field_ast(lexer) {
    Ok(n) => n
    Err(e) => return Err(e)
  }
  
  let remaining = match lexer.peek_token() {
    Ok(t) => t
    Err(e) => return Err(e)
  }
  if remaining != EOF {
    return Err(InvalidFormat("Cron expression has too many fields"))
  }

  let minutes = match minutes_node.to_array(0, 59) {
    Ok(arr) => arr
    Err(e) => return Err(e)
  }
  let hours = match hours_node.to_array(0, 23) {
    Ok(arr) => arr
    Err(e) => return Err(e)
  }
  let days_of_month = match days_of_month_node.to_array(1, 31) {
    Ok(arr) => arr
    Err(e) => return Err(e)
  }
  let months = match months_node.to_array(1, 12) {
    Ok(arr) => arr
    Err(e) => return Err(e)
  }
  let days_of_week = match days_of_week_node.to_array(0, 6) {
    Ok(arr) => arr
    Err(e) => return Err(e)
  }

  Ok({
    minutes,
    hours,
    days_of_month,
    months,
    days_of_week
  })
}

///|
fn usage() -> @argparse.Command {
  @argparse.Command("cron-mbt", about="MoonBit cron parser and scheduler CLI", subcommands=[
    @argparse.Command(
      "parse",
      about="Parse a cron expression and print the normalized fields",
      positionals=[@argparse.PositionArg("expr")],
    ),
    @argparse.Command(
      "next",
      about="Calculate the next trigger time after a timestamp",
      positionals=[
        @argparse.PositionArg("expr"),
        @argparse.PositionArg("year"),
        @argparse.PositionArg("month"),
        @argparse.PositionArg("day"),
        @argparse.PositionArg("hour"),
        @argparse.PositionArg("minute"),
      ],
    ),
    @argparse.Command(
      "match",
      about="Check whether a timestamp matches a cron expression",
      positionals=[
        @argparse.PositionArg("expr"),
        @argparse.PositionArg("year"),
        @argparse.PositionArg("month"),
        @argparse.PositionArg("day"),
        @argparse.PositionArg("hour"),
        @argparse.PositionArg("minute"),
        @argparse.PositionArg("weekday"),
      ],
    ),
    @argparse.Command(
      "explain",
      about="Print a canonical expression and an operational explanation",
      positionals=[@argparse.PositionArg("expr")],
    ),
    @argparse.Command(
      "next-many",
      about="Print a bounded batch of next trigger times",
      positionals=[
        @argparse.PositionArg("expr"),
        @argparse.PositionArg("year"),
        @argparse.PositionArg("month"),
        @argparse.PositionArg("day"),
        @argparse.PositionArg("hour"),
        @argparse.PositionArg("minute"),
        @argparse.PositionArg("count"),
      ],
    ),
    @argparse.Command(
      "previous",
      about="Print the previous trigger time before a timestamp",
      positionals=[
        @argparse.PositionArg("expr"),
        @argparse.PositionArg("year"),
        @argparse.PositionArg("month"),
        @argparse.PositionArg("day"),
        @argparse.PositionArg("hour"),
        @argparse.PositionArg("minute"),
      ],
    ),
    @argparse.Command(
      "validate",
      about="Validate a timestamp before submitting a schedule",
      positionals=[
        @argparse.PositionArg("year"),
        @argparse.PositionArg("month"),
        @argparse.PositionArg("day"),
        @argparse.PositionArg("hour"),
        @argparse.PositionArg("minute"),
      ],
    ),
  ])
}

///|
fn get_required(matches : @argparse.Matches, name : String) -> String {
  match matches.values.get(name) {
    Some(values) => values[0]
    None => panic()
  }
}

///|
fn parse_int_arg(matches : @argparse.Matches, name : String) -> Int {
  @string.parse_int(get_required(matches, name)) catch {
    _ => panic()
  }
}

///|
fn two_digits(value : Int) -> String {
  if value < 10 {
    "0" + value.to_string()
  } else {
    value.to_string()
  }
}

///|
fn print_expr(expr : @cron.CronExpr) -> Unit {
  println("minutes=\{@cron.format_int_list(expr.minutes)}")
  println("hours=\{@cron.format_int_list(expr.hours)}")
  println("days_of_month=\{@cron.format_int_list(expr.days_of_month)}")
  println("months=\{@cron.format_int_list(expr.months)}")
  println("days_of_week=\{@cron.format_int_list(expr.days_of_week)}")
  println("has_last_day_of_month=\{expr.has_last_day_of_month}")
}

///|
fn print_datetime(dt : @cron.DateTime) -> Unit {
  println(
    "\{dt.year}-\{two_digits(dt.month)}-\{two_digits(dt.day)} \{two_digits(dt.hour)}:\{two_digits(dt.minute)}",
  )
}

///|
fn get_datetime(matches : @argparse.Matches) -> @cron.DateTime {
  {
    year: parse_int_arg(matches, "year"),
    month: parse_int_arg(matches, "month"),
    day: parse_int_arg(matches, "day"),
    hour: parse_int_arg(matches, "hour"),
    minute: parse_int_arg(matches, "minute"),
  }
}

///|
fn main {
  let matches = usage().parse() catch { _ => return }
  match matches.subcommand {
    Some(("parse", sub)) => {
      let raw = get_required(sub, "expr")
      match @cron.parse(raw) {
        Ok(expr) => print_expr(expr)
        Err(err) => println(err.to_string())
      }
    }
    Some(("next", sub)) => {
      let raw = get_required(sub, "expr")
      let current = get_datetime(sub)
      match @cron.parse(raw) {
        Ok(expr) =>
          match expr.next_time(current) {
            Ok(next) => print_datetime(next)
            Err(err) => println(err.to_string())
          }
        Err(err) => println(err.to_string())
      }
    }
    Some(("explain", sub)) =>
      match @cron.parse(get_required(sub, "expr")) {
        Ok(expr) => {
          println("canonical=\{expr.canonical()}")
          println("description=\{expr.describe()}")
        }
        Err(err) => println(err.to_string())
      }
    Some(("next-many", sub)) =>
      match @cron.parse(get_required(sub, "expr")) {
        Ok(expr) =>
          match
            expr.next_times(get_datetime(sub), parse_int_arg(sub, "count")) {
            Ok(values) =>
              for value in values {
                print_datetime(value)
              }
            Err(err) => println(err.to_string())
          }
        Err(err) => println(err.to_string())
      }
    Some(("previous", sub)) =>
      match @cron.parse(get_required(sub, "expr")) {
        Ok(expr) =>
          match expr.previous_time(get_datetime(sub)) {
            Ok(value) => print_datetime(value)
            Err(err) => println(err.to_string())
          }
        Err(err) => println(err.to_string())
      }
    Some(("validate", sub)) => {
      let datetime = get_datetime(sub)
      match datetime.validate() {
        Ok(_) => println("valid")
        Err(err) => println("invalid: \{err}")
      }
    }
    Some(("match", sub)) => {
      let raw = get_required(sub, "expr")
      match @cron.parse(raw) {
        Ok(expr) => {
          let matched = expr.matches(
            parse_int_arg(sub, "year"),
            parse_int_arg(sub, "minute"),
            parse_int_arg(sub, "hour"),
            parse_int_arg(sub, "day"),
            parse_int_arg(sub, "month"),
            parse_int_arg(sub, "weekday"),
          )
          println(matched.to_string())
        }
        Err(err) => println(err.to_string())
      }
    }
    _ => println(usage().render_help())
  }
}

# cron_mbt

[![MoonBit CI](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml/badge.svg)](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml)

a simple and fast cron expression parser and scheduler written in MoonBit. 
created for the 2026 OSC Track 1 MoonBit Competition.

## features
- parses standard 5-field cron expressions
- supports macros like `@hourly`, `@daily`, etc.
- calculates the next execution time based on current time
- lexer and ast based, zero dependencies

## usage

add to `moon.mod.json`:
```json
{
  "deps": {
    "cxh0404/cron_mbt": "0.1.0"
  }
}
```

simple parsing and matching:
```moonbit
let expr = @cron.parse("*/5 8-10 * * 1-5").unwrap()

let is_match = expr.matches(
  year = 2026,
  minute = 15,
  hour = 9,
  day_of_month = 10,
  month = 6,
  day_of_week = 3
)
// true
```

getting next execution time:
```moonbit
let expr = @cron.parse("@hourly").unwrap()
let current_time = { year: 2026, month: 6, day: 10, hour: 9, minute: 14 }
let next_trigger = expr.next_time(current_time).unwrap()
// 10:00
```

## dev
run tests:
```bash
moon test
```

## license
Apache 2.0


# Cron-Mbt

A lightweight cron expression parser and scheduler written in MoonBit.
This project is participating in the 2026 OSC Track 1 MoonBit Competition.

## Features
- Parse standard 5-field cron expressions.
- Match a specific time against a cron expression.
- High test coverage and robust error handling.

## Usage
```moonbit
let cron = @cron.parse("0 12 * * 1").unwrap()
let is_match = cron.matches(0, 12, 15, 6, 1)
```


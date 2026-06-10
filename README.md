# Cron-Mbt 🕒

[![MoonBit CI](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml/badge.svg)](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A highly robust, high-performance Cron expression parser and scheduling engine native to MoonBit.

Designed specially for the **2026 OSC Track 1 MoonBit Competition**.

## ✨ Features

- **Standard Compliance**: Fully parses 5-field cron strings (Minute, Hour, Day of Month, Month, Day of Week).
- **Advanced Syntax**: Full support for wildcards (`*`), ranges (`-`), lists (`,`), and steps (`/`).
- **Macro Extensions**: Built-in support for aliases like `@hourly`, `@daily`, `@weekly`, `@monthly`, and `@yearly`.
- **Lexer-Driven Architecture**: Implements a zero-allocation state-machine lexer (`lexer.mbt`) and AST-based parser.
- **Time Calculations**: The `schedule.mbt` module calculates exactly *when* the next trigger occurs, handling leap years and variable month lengths flawlessly.
- **Pure & Type-Safe**: Avoids panic/exceptions. Uses MoonBit's `Result` type strictly for robust error handling in production.

## 📦 Installation

Since MoonBit's package management is actively evolving, you can install this package by adding it to your `moon.mod.json`:

```json
{
  "deps": {
    "cxh0404/cron_mbt": "0.1.0"
  }
}
```

## 🚀 Quick Start

### 1. Basic Matching

```moonbit
let expr = @cron.parse("*/5 8-10 * * 1-5").unwrap()

// Check if a specific timestamp matches
let is_match = expr.matches(
  minute = 15,
  hour = 9,
  day_of_month = 10,
  month = 6,
  day_of_week = 3
)
println(is_match) // true
```

### 2. Schedule Calculation (Next Execution)

```moonbit
let expr = @cron.parse("@hourly").unwrap()
let current_time = { year: 2026, month: 6, day: 10, hour: 9, minute: 14 }

let next_trigger = expr.next_time(current_time).unwrap()
// next_trigger => { year: 2026, month: 6, day: 10, hour: 10, minute: 0 }
```

## 🛠️ Internal Architecture

This package is designed using a multi-pass compilation architecture similar to actual compilers:

1. **Lexical Analysis**: Raw cron strings are converted into a stream of `Token` variants (`Number`, `Asterisk`, `Slash`, etc.).
2. **AST Construction**: Tokens are grouped into meaningful field syntax nodes (`Value`, `Range`, `Step`, `List`).
3. **Evaluation**: Nodes are mapped and evaluated against valid boundary constraints into raw lookup arrays for O(1) matching performance.

## 🤝 Contributing

Contributions, issues, and feature requests are highly welcome.
Please feel free to check the [issues page](https://github.com/cxh04/Cron-Mbt/issues) if you want to contribute.

## 📝 License

This project is licensed under the Apache License 2.0 - see the `LICENSE` file for details.

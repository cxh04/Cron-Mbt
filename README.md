# Cron-Mbt

[![MoonBit CI](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml/badge.svg)](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml)
![MoonBit](https://img.shields.io/badge/MoonBit-OSC2026-blue)
![License](https://img.shields.io/badge/license-Apache--2.0-green)

`Cron-Mbt` is a MoonBit cron expression library with a real parser,
deterministic matcher, next-trigger calculator, and usable CLI. It is scoped
to five-field cron expressions: minute, hour, day-of-month, month, and
day-of-week. Time zones, seconds, and year fields are outside the current API
boundary.

## What It Supports

- Standard five-field cron expressions: minute, hour, day-of-month, month, and
  day-of-week.
- Core operators: `*`, `?`, `,`, `-`, `/`, and `L` for the last day of month.
  `L` is accepted only in the day-of-month field; invalid placements return
  `Err`.
- Macro aliases: `@yearly`, `@annually`, `@monthly`, `@weekly`, `@daily`,
  `@midnight`, and `@hourly`.
- Day matching semantics aligned with common cron behavior: when both
  day-of-month and day-of-week are constrained, either side may satisfy the
  schedule.
- Sunday normalization for both `0` and `7`.
- A CLI that parses expressions, checks matches, and computes the next trigger
  time.

## Why This Revision Matters

The organizer feedback identified concrete gaps in CI, invalid-expression
handling, `L` placement, regression coverage, and release documentation. This
revision addresses those items with explicit command stages, parser errors,
calendar boundary tests, and a deterministic operations-style corpus.

## Project Layout

```text
src/cron/   core parser, matcher, scheduler, tests
src/cli/    command-line interface
benchmarks/ public-API conformance corpus
docs/       architecture, API reference, acceptance notes, source notes
scripts/    validation and baseline helper scripts
.github/    GitHub Actions workflow
```

## Installation

Add the module to your `moon.mod` import block:

```toml
import {
  "cxh04/cron_mbt@0.2.2",
}
```

## Library Usage

Parse and inspect an expression:

```moonbit
let expr = @cron.parse("*/5 8-10 ? * 1-5").unwrap()
```

Check whether a timestamp matches:

```moonbit
let matched = expr.matches(
  year = 2026,
  minute = 15,
  hour = 9,
  day_of_month = 10,
  month = 6,
  day_of_week = 3,
)
```

Compute the next trigger time:

```moonbit
let expr = @cron.parse("30 9 * * 1").unwrap()
let current = {
  year: 2026,
  month: 6,
  day: 9,
  hour: 10,
  minute: 0,
}
let next = expr.next_time(current).unwrap()
// 2026-06-15 09:30
```

## CLI Usage

Parse:

```bash
moon run src/cli parse "0 9 ? * 1-5"
```

Next trigger:

```bash
moon run src/cli next "30 9 * * 1" 2026 6 9 10 0
```

Match a timestamp:

```bash
moon run src/cli match "15 10 * * *" 2026 6 10 10 15 3
```

## Verification

The local and CI checks are:

```bash
moon check --target all --deny-warn
moon build --target all
moon fmt
moon info
moon test --target all --deny-warn
moon test benchmarks
powershell -ExecutionPolicy Bypass -File ./scripts/verify_acceptance.ps1 -SkipMooncakes
```

The CI workflow uses the official MoonBit installer, prints
`moon version --all`, and runs the required `moon check`, `moon build`,
`moon fmt`, `moon info`, and `moon test` stages on Ubuntu, macOS, and Windows.

The deterministic acceptance corpus is under `benchmarks/`; it covers
operations-style schedules, month ends, leap years, calendar transitions, and
weekday semantics. `scripts/benchmark.ps1` provides a repeatable end-to-end
CLI baseline for the current machine. Its timings are regression data, not a
portable performance claim.

## Mooncakes Status

- Module name: `cxh04/cron_mbt`
- Manifest version: `0.2.2`
- `moon publish --dry-run` validates packaging before publication
- version `0.2.2` contains the acceptance corpus, cross-platform CI, and
  documentation fixes

## Documents

- [Architecture](docs/architecture.md)
- [API Reference](docs/api_reference.md)
- [Acceptance Notes](docs/acceptance.md)
- [Submission Status](docs/submission_status.md)
- [Source Attribution](docs/source_attribution.md)
- [Benchmark Corpus](benchmarks/README.md)

## License

Apache-2.0. See [LICENSE](LICENSE).

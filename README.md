# Cron-Mbt

[![MoonBit CI](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml/badge.svg)](https://github.com/cxh04/Cron-Mbt/actions/workflows/moonbit-ci.yml)
![MoonBit](https://img.shields.io/badge/MoonBit-OSC2026-blue)
![License](https://img.shields.io/badge/license-Apache--2.0-green)

`Cron-Mbt` is a MoonBit cron expression library with a real parser, deterministic matcher, next-trigger calculator, and a usable CLI. The repository is being hardened for the MoonBit OSC2026 acceptance checklist, so the focus is on runnable examples, CI completeness, source clarity, and publish readiness rather than marketing-heavy claims.

## What It Supports

- Standard 5-field cron expressions: minute, hour, day-of-month, month, day-of-week.
- Core operators: `*`, `?`, `,`, `-`, `/`, and `L` for the last day of month.
  `L` is accepted only in the day-of-month field; invalid placements return `Err`.
- Macro aliases: `@yearly`, `@annually`, `@monthly`, `@weekly`, `@daily`, `@midnight`, `@hourly`.
- Day matching semantics aligned with common cron behavior:
  when both day-of-month and day-of-week are constrained, either side may satisfy the schedule.
- Sunday normalization for both `0` and `7`.
- A CLI that can parse expressions, check matches, and compute the next trigger time.

## Why This Revision Matters

The organizer feedback highlighted several concrete gaps:

- deprecated warnings blocked `moon info` / `moon fmt` style checks
- CI did not cover the required `check/build/fmt/info/test` stages
- the CLI was mostly a placeholder
- the next-trigger logic was still minute-by-minute brute force and missed weekday constraints
- Mooncakes metadata was incomplete

This revision addresses those issues directly.

## Project Layout

```text
src/cron/   core parser, matcher, scheduler, tests
src/cli/    command-line interface
docs/       architecture, API reference, acceptance notes, source notes
scripts/    validation and helper scripts
.github/    GitHub Actions workflow
```

## Installation

Add the module to `moon.mod`:

```toml
[deps]
"cxh04/cron_mbt" = "0.2.1"
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

Local checks used during this hardening pass:

```bash
moon check --deny-warn
moon build
moon fmt
moon info
moon test --deny-warn
moon run src/cli parse "0 9 ? * 1-5"
moon run src/cli next "30 9 * * 1" 2026 6 9 10 0
pwsh ./scripts/verify_acceptance.ps1
```

The CI workflow uses the official MoonBit installer, prints `moon version --all`,
and runs `moon check --deny-warn`, `moon build`, `moon fmt`, `moon info`, and
`moon test --deny-warn`.

## Mooncakes Status

- Module name: `cxh04/cron_mbt`
- Manifest version: `0.2.1`
- `moon publish --dry-run` validates packaging before publication
- version `0.2.1` contains the OSC2026 acceptance feedback fixes

## Documents

- [Architecture](docs/architecture.md)
- [API Reference](docs/api_reference.md)
- [Acceptance Notes](docs/acceptance.md)
- [Submission Status](docs/submission_status.md)
- [Source Attribution](docs/source_attribution.md)

## License

Apache-2.0

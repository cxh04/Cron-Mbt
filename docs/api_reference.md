# API Reference

## `parse(expr: String) -> Result[CronExpr, CronError]`

Parses a raw five-field cron string. Supported macros include `@hourly`,
`@daily`, `@weekly`, `@monthly`, and `@yearly`.

Invalid expressions return `Err(CronError)` instead of being accepted silently.
The `L` token is only valid in the day-of-month field.

## `CronExpr::matches(year, minute, hour, day_of_month, month, day_of_week) -> Bool`

Validates whether a time tuple fulfills the cron constraints. Sunday may be
provided as either `0` or `7`; day-of-month and day-of-week constraints follow
the standard cron OR rule when both are restricted.

## `CronExpr::next_time(current: DateTime) -> Result[DateTime, CronError]`

Computes the precise next execution time based on leap years and calendar math.
The returned time is strictly later than `current`. If the expression cannot
produce a calendar date, the function returns `Err(CronError)`.

## Supported Boundary Behavior

- `L` means the last calendar day and is accepted only in the day-of-month
  field; `L` combined with a step returns `Err`.
- Out-of-range values, zero steps, malformed ranges, unknown characters, and
  missing or extra fields return `Err` during parsing.
- `?` is treated as a wildcard in the day-of-month/day-of-week positions.

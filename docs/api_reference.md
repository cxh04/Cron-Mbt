# API Reference

## `parse(expr: String) -> Result[CronExpr, CronError]`
Parses a raw cron string. Supports macros (`@hourly`, etc).

## `CronExpr::matches(minute, hour, day_of_month, month, day_of_week) -> Bool`
Validates if a given time tuple fulfills the cron constraints.

## `CronExpr::next_time(current: DateTime) -> Result[DateTime, CronError]`
Computes the precise next execution time based on leap years and calendar math.

# Architecture Overview

Cron-Mbt uses a small compiler-like pipeline. Parsing creates a normalized AST
and field arrays once; matching then uses deterministic array lookups, while
the scheduler advances by valid month, day, hour, and minute buckets.

## 1. Lexical Scanner

The lexer (`lexer.mbt`) reads the raw expression and converts it into a token
stream. It handles numeric values, whitespace, bounds-independent operators,
and the `L` and `?` tokens.

## 2. AST Parser

The parser (`parser.mbt`) constructs an AST for each field, expands supported
macros, normalizes Sunday `7` to `0`, and validates field-specific rules. It
rejects malformed tokens, field counts, ranges, steps, out-of-range values, and
illegal `L` placement with `CronError`.

## 3. Evaluator

The matcher (`matcher.mbt`) consumes normalized field arrays and applies the
day-of-month/day-of-week OR rule. The schedule engine (`schedule.mbt`) skips
invalid calendar days and disallowed field buckets instead of enumerating every
minute across the whole search window. Month-end `L` handling uses the actual
length of the selected year and month.

## 4. Validation Boundary

The parser is the trust boundary for expression syntax. The regression suite
exercises both valid schedules and expected failures so invalid input does not
reach unchecked array indexing. The public `DateTime` value is deliberately a
small calendar tuple; timezone and seconds handling are outside the current
module boundary.

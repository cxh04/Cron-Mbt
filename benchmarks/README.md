# Cron-Mbt Benchmark Corpus

This directory contains a deterministic conformance corpus for the public
parser, matcher, and next-trigger APIs. It is based on schedules seen in
routine operations work: weekday maintenance, CI windows, report generation,
month-end jobs, and release automation.

The corpus covers:

- 24 next-trigger cases across step, range, list, macro, weekday, month, and
  question-mark wildcard expressions.
- Leap years including the century boundary rule (`2000` is leap and `1900` is
  not), February 29, 30-day months, 31-day months, and `L` month-end cases.
- Cross-weekend, cross-month, and cross-year transitions.
- Cron day-of-month/day-of-week OR semantics and Sunday aliases `0` and `7`.

Run the deterministic corpus with:

```bash
moon test benchmarks
```

For a repeatable end-to-end CLI baseline, run:

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/benchmark.ps1 -Iterations 3
```

The script reports the number of cases and wall-clock time on the current
machine. It is a regression baseline for the same environment, not a portable
performance claim across different operating systems or MoonBit toolchains.

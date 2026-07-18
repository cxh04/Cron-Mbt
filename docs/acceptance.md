# Acceptance Notes

This document maps the OSC2026 acceptance-facing repository requirements to concrete repository evidence.

## Acceptance Baseline Rechecked On 2026-07-19

From the current public OSC2026 site source:

- proposal submission closes on `2026-07-12`
- acceptance expects MoonBit to be the primary implementation language
- the repository should be public
- the project should provide a clear README
- runnable examples, CI, tests, and Mooncakes publication are expected
- the reference source scale is `4~10k LOC`, but usability, scope clarity, tests, docs, and maintainability matter more than hitting the number mechanically

## Repository Evidence

- Public GitHub repo: `https://github.com/cxh04/Cron-Mbt`
- Public GitLink repo: `https://gitlink.org.cn/cxh0404/Cron-Mbt`
- Default branch target: `master`
- License present: `LICENSE`
- README present: `README.md`
- Core MoonBit source: `src/cron/*.mbt`, `src/cli/main.mbt`
- GitHub Actions workflow: `.github/workflows/moonbit-ci.yml`
- Validation script: `scripts/verify_acceptance.ps1`
- Release tag: `v0.2.1`

## Hardening Completed In This Pass

- migrated deprecated `moon.mod.json` / `moon.pkg.json` files to `moon.mod` / `moon.pkg`
- removed `derive(Show)`-style deprecated warnings from the checked code paths
- expanded syntax support to include `?` and Sunday normalization for `7`
- fixed day-of-month/day-of-week matching semantics
- restricted `L` to the day-of-month field and return `Err` for invalid placements
- added malformed-expression regression tests for bounds, steps, invalid tokens, and invalid `L`
- fixed next-trigger calculation to respect weekday constraints and skip by valid month/hour/minute buckets instead of scanning every minute forever
- replaced the placeholder CLI with real `parse`, `next`, and `match` subcommands
- expanded CI to include the required `moon check`, `moon build`, `moon fmt`, `moon info`, and `moon test` stages
- removed invalid `--deny-warn` arguments from `moon fmt` and `moon info`

## Remaining External Checks

- Mooncakes publication owner: `cxh04`
- GitHub repository owner: `cxh04`
- GitLink repository owner: `cxh0404`
- Both GitHub and GitLink should be pushed after each acceptance hardening pass.

# Acceptance Notes

This document maps OSC2026 acceptance-facing repository requirements to
concrete repository evidence.

## Acceptance Baseline Rechecked On 2026-08-10

The official OSC2026 site currently describes project acceptance as
`2026-07-13` to `2026-07-17`. The organizer email supplied by the participant
allows this project to continue updating through `2026-08-17`; that later
project-specific notice is the deadline used for this hardening pass.

The official site describes the following acceptance cues:

- MoonBit should be the primary implementation language.
- The repository should be public and contain a clear README, source, commits,
  and an OSI-approved license.
- The project should provide runnable examples, CI, tests, Mooncakes
  publication, and a maintainable scope.
- `4~10k LOC` is a reference range, not a mechanical acceptance threshold;
  usability, scope clarity, runnable tests, documentation, and maintainability
  matter more than reaching the number by padding code.

## Repository Evidence

- Public GitHub repo: `https://github.com/cxh04/Cron-Mbt`
- Public GitLink repo: `https://gitlink.org.cn/cxh0404/Cron-Mbt`
- Default branch target: `master`
- License present: `LICENSE` (Apache-2.0)
- README present: `README.md`
- Core MoonBit source: `src/cron/*.mbt`, `src/cli/main.mbt`
- Public-API corpus: `benchmarks/corpus_test.mbt`
- GitHub Actions workflow: `.github/workflows/moonbit-ci.yml`
- Validation script: `scripts/verify_acceptance.ps1`
- CLI baseline: `scripts/benchmark.ps1`
- Release tag for this hardening pass: `v0.2.2`

## Hardening Completed In This Pass

- CI explicitly contains `moon check`, `moon build`, `moon fmt`, `moon info`,
  and `moon test`, following the community workflow-template installation
  shape on Ubuntu, macOS, and Windows.
- Removed invalid warning flags from `moon fmt` and `moon info`.
- Restricted `L` to the day-of-month field and return `Err` for invalid
  placements or `L` step expressions.
- Added malformed-expression regression tests for bounds, steps, invalid
  tokens, and invalid `L` usage.
- Added a 30+ case operations-style conformance corpus for parser, matcher,
  scheduler, leap years, month ends, weekdays, and cross-calendar transitions.
- Added a repeatable CLI baseline script with explicit limits on what its timing
  numbers mean.
- Corrected the public API reference, module installation example, contributor
  workflow, and source-attribution notes.

## External Checks Required Before Final Submission

- Mooncakes owner and package: `cxh04/cron_mbt`
- GitHub repository owner: `cxh04`
- GitLink repository owner: `cxh0404`
- Both public repositories must expose the synchronized `master` commit and
  `v0.2.2` tag before submitting the final acceptance materials.
- A new Mooncakes version must be published for any post-`0.2.1` code change,
  because registry versions are immutable.

# Submission Status

Checked on `2026-08-10`.

## Local Verification Targets

- `moon check --target all --deny-warn`
- `moon build --target all`
- `moon fmt`
- `moon info`
- `moon test --target all --deny-warn`
- `moon test benchmarks`
- `scripts/verify_acceptance.ps1 -SkipMooncakes`
- `scripts/benchmark.ps1 -Iterations 3`

## Repository State To Verify At Release Time

- GitHub default branch: `master`
- GitLink default branch: `master`
- GitHub and GitLink tag: `v0.2.3` for this hardening pass
- GitHub sole contributor target: `cxh04`
- GitLink sole contributor target: `cxh0404`
- Mooncakes module: `cxh04/cron_mbt`

## Publication State

Version `0.2.1` was published before this hardening pass. Mooncakes versions
are immutable; this pass will publish `0.2.3` after all checks pass.

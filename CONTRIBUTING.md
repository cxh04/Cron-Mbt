# Contributing

Cron-Mbt is a small, public MoonBit library. Changes should stay within the
documented five-field cron scope unless the README, API reference, tests, and
release notes are updated together.

## Before Opening A Pull Request

Run the same checks used by CI:

```bash
moon check --target all --deny-warn
moon build --target all
moon fmt
moon info
moon test --target all --deny-warn
```

Also run the acceptance self-check when working on packaging, documentation,
or release metadata:

```powershell
powershell -ExecutionPolicy Bypass -File ./scripts/verify_acceptance.ps1 -SkipMooncakes
```

Add regression tests for parser failures and calendar boundaries. Keep public
API changes intentional, document them in `docs/api_reference.md`, and record
any third-party references in `docs/source_attribution.md`.

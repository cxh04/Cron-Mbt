#!/usr/bin/env bash
set -euo pipefail

parse_output="$(moon run src/cli --target wasm-gc parse '0 9 * * 1-5')"
printf '%s\n' "$parse_output" | grep -F 'minutes=[0]' >/dev/null
printf '%s\n' "$parse_output" | grep -F 'days_of_week=[1, 2, 3, 4, 5]' >/dev/null

next_output="$(moon run src/cli --target wasm-gc next '0 9 * * 1-5' 2026 8 7 10 0)"
test "$next_output" = '2026-08-10 09:00'

match_output="$(moon run src/cli --target wasm-gc match '0 9 * * *' 2026 8 10 9 0 1)"
test "$match_output" = 'true'

explain_output="$(moon run src/cli --target wasm-gc explain '0 0 L * *')"
printf '%s\n' "$explain_output" | grep -F 'canonical=0 0 L * *' >/dev/null
printf '%s\n' "$explain_output" | grep -F 'last day' >/dev/null

validate_output="$(moon run src/cli --target wasm-gc validate 2026 2 29 9 0)"
printf '%s\n' "$validate_output" | grep -F 'invalid' >/dev/null

echo 'CLI smoke tests passed'

$ErrorActionPreference = "Stop"

$parse = moon run src/cli --target wasm-gc parse "0 9 * * 1-5"
if (-not ($parse -contains "minutes=[0]")) { throw "parse minutes failed" }
if (-not ($parse -contains "days_of_week=[1, 2, 3, 4, 5]")) { throw "parse weekdays failed" }

$next = moon run src/cli --target wasm-gc next "0 9 * * 1-5" 2026 8 7 10 0
if ($next.Trim() -ne "2026-08-10 09:00") { throw "next failed: $next" }

$match = moon run src/cli --target wasm-gc match "0 9 * * *" 2026 8 10 9 0 1
if ($match.Trim() -ne "true") { throw "match failed: $match" }

$explain = moon run src/cli --target wasm-gc explain "0 0 L * *"
if (-not ($explain -match "canonical=0 0 L \* \*")) { throw "explain canonical failed" }
if (-not ($explain -match "last day")) { throw "explain description failed" }

$validate = moon run src/cli --target wasm-gc validate 2026 2 29 9 0
if (-not ($validate -match "invalid")) { throw "validate failed" }

Write-Host "CLI smoke tests passed"

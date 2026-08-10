param(
  [ValidateRange(1, 100)]
  [int]$Iterations = 3
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$parseCases = @(
  "*/5 * * * *",
  "0 2 * * 1-5",
  "15 6 1,15 * *",
  "*/15 9-17 * * 1-5",
  "0 0 L * *",
  "0 0 29 2 *",
  "0 0 ? * 1-5",
  "@hourly",
  "@monthly"
)

$nextCases = @(
  @("*/5 * * * *", 2026, 8, 10, 12, 1),
  @("0 2 * * 1-5", 2026, 8, 14, 2, 1),
  @("0 0 L * *", 2024, 2, 1, 0, 0),
  @("0 0 29 2 *", 2023, 3, 1, 0, 0),
  @("0 0 30 * *", 2026, 1, 31, 0, 0),
  @("*/15 9-17 * * 1-5", 2026, 8, 14, 17, 59)
)

function Invoke-CronCli([string[]]$Arguments) {
  & moon run src/cli @Arguments | Out-Null
  if ($LASTEXITCODE -ne 0) {
    throw "moon run src/cli failed for: $($Arguments -join ' ')"
  }
}

$parseElapsed = Measure-Command {
  for ($iteration = 0; $iteration -lt $Iterations; $iteration++) {
    foreach ($expression in $parseCases) {
      Invoke-CronCli @("parse", $expression)
    }
  }
}

$nextElapsed = Measure-Command {
  for ($iteration = 0; $iteration -lt $Iterations; $iteration++) {
    foreach ($case in $nextCases) {
      Invoke-CronCli @(
        "next", $case[0], "$($case[1])", "$($case[2])", "$($case[3])",
        "$($case[4])", "$($case[5])"
      )
    }
  }
}

Write-Host "Cron-Mbt CLI baseline" -ForegroundColor Green
Write-Host "toolchain: $(moon version)"
Write-Host "iterations: $Iterations"
Write-Host "parse cases: $($parseCases.Count)"
Write-Host "next cases: $($nextCases.Count)"
Write-Host ("parse elapsed: {0:N3}s" -f $parseElapsed.TotalSeconds)
Write-Host ("next elapsed:  {0:N3}s" -f $nextElapsed.TotalSeconds)

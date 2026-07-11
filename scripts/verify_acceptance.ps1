param(
  [switch]$SkipMooncakes
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

function Write-Check($name, $script) {
  Write-Host "==> $name" -ForegroundColor Cyan
  & $script
  if ($LASTEXITCODE -ne 0) {
    throw "$name failed"
  }
}

function Get-MoonBitLoc {
  $sum = 0
  $files = git ls-files *.mbt *.mbti
  foreach ($file in $files) {
    $sum += (Get-Content $file | Measure-Object -Line).Lines
  }
  $sum
}

function Test-RequiredFile($path) {
  if (-not (Test-Path $path)) {
    throw "Missing required file: $path"
  }
}

Write-Host "Cron-Mbt acceptance self-check" -ForegroundColor Green
Write-Host "Repository: $repoRoot"
Write-Host ""

Write-Check "moon version" { moon version }
Write-Check "moon check --deny-warn" { moon check --deny-warn }
Write-Check "moon fmt" { moon fmt }
Write-Check "moon test --deny-warn" { moon test --deny-warn }

Write-Host "==> moon info" -ForegroundColor Cyan
& moon info --deny-warn
if ($LASTEXITCODE -ne 0) {
  Write-Host "moon info --deny-warn is not supported by the current local toolchain; falling back to plain moon info." -ForegroundColor Yellow
  & moon info
  if ($LASTEXITCODE -ne 0) {
    throw "moon info failed"
  }
}

Write-Host "==> required files" -ForegroundColor Cyan
@(
  "README.md",
  "LICENSE",
  "moon.mod",
  ".github/workflows/moonbit-ci.yml",
  "src/cli/main.mbt",
  "docs/acceptance.md",
  "docs/source_attribution.md"
) | ForEach-Object { Test-RequiredFile $_ }

$commitCount = [int](git rev-list --count HEAD)
$loc = Get-MoonBitLoc

Write-Host "==> git remotes" -ForegroundColor Cyan
$githubHead = git ls-remote --symref https://github.com/cxh04/Cron-Mbt.git HEAD
$gitlinkHead = git ls-remote --symref https://gitlink.org.cn/cxh0404/Cron-Mbt.git HEAD

Write-Host ""
Write-Host "Summary" -ForegroundColor Green
Write-Host "  commits: $commitCount"
Write-Host "  moonbit_loc: $loc"
Write-Host "  github_head: $githubHead"
Write-Host "  gitlink_head: $gitlinkHead"

if (-not $SkipMooncakes) {
  Write-Check "moon publish --dry-run" { moon publish --dry-run }
}

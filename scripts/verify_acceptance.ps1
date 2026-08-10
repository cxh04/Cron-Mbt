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

function Get-ManifestVersion {
  $match = Select-String -Path "moon.mod" -Pattern '^version\s*=\s*"([^"]+)"'
  if ($null -eq $match) {
    throw "moon.mod has no version"
  }
  $match.Matches[0].Groups[1].Value
}

function Get-RemoteHead($label, $url) {
  $lines = @(git ls-remote --symref $url HEAD)
  if ($LASTEXITCODE -ne 0 -or $lines.Count -eq 0) {
    throw "$label HEAD lookup failed"
  }
  $expected = "ref: refs/heads/master`tHEAD"
  if (-not ($lines -contains $expected)) {
    throw "$label default branch is not master"
  }
  $shaLine = $lines | Where-Object { $_ -match '^[0-9a-f]{40}\tHEAD$' }
  if ($null -eq $shaLine) {
    throw "$label HEAD SHA is missing"
  }
  $shaLine.Split("`t")[0]
}

Write-Host "Cron-Mbt acceptance self-check" -ForegroundColor Green
Write-Host "Repository: $repoRoot"
Write-Host ""

Write-Check "moon version" { moon version --all }
Write-Check "moon check --deny-warn" { moon check --deny-warn }
Write-Check "moon build" { moon build }
Write-Check "moon fmt" { moon fmt }
Write-Check "moon info" { moon info }
Write-Check "moon test --deny-warn" { moon test --deny-warn }

Write-Host "==> required files" -ForegroundColor Cyan
@(
  "README.md",
  "LICENSE",
  "moon.mod",
  ".github/workflows/moonbit-ci.yml",
  "src/cli/main.mbt",
  "benchmarks/moon.pkg",
  "benchmarks/corpus_test.mbt",
  "benchmarks/README.md",
  "scripts/benchmark.ps1",
  "docs/acceptance.md",
  "docs/source_attribution.md"
) | ForEach-Object { Test-RequiredFile $_ }

$manifestVersion = Get-ManifestVersion
$tag = "v$manifestVersion"
$cliVersion = Select-String -Path "src/cli/moon.pkg" -Pattern 'src/cron"\s*:\s*"([^"]+)"'
if ($null -eq $cliVersion -or $cliVersion.Matches[0].Groups[1].Value -ne $manifestVersion) {
  throw "CLI dependency version does not match moon.mod"
}

$workflow = Get-Content -Raw ".github/workflows/moonbit-ci.yml"
foreach ($requiredCommand in @("moon check", "moon build", "moon fmt", "moon info", "moon test")) {
  if ($workflow -notmatch [regex]::Escape($requiredCommand)) {
    throw "CI is missing required command: $requiredCommand"
  }
}

$licenseText = Get-Content -Raw LICENSE
if ($licenseText -notmatch "Apache License[\s\S]+Version 2.0") {
  throw "LICENSE is not the full Apache-2.0 text"
}
if (-not (Select-String -Path README.md -Pattern "Apache-2.0")) {
  throw "README does not identify the license"
}

$commitCount = [int](git rev-list --count HEAD)
$loc = Get-MoonBitLoc
if ($loc -lt 1000) {
  throw "MoonBit source/test scale is unexpectedly small: $loc lines"
}
$authors = @(git log --format='%ae' HEAD | Sort-Object -Unique)
$allowedAuthors = @("cxh0404@example.com", "cxh04@users.noreply.github.com")
$unexpectedAuthors = @($authors | Where-Object { $_ -notin $allowedAuthors })
if ($unexpectedAuthors.Count -gt 0) {
  throw "Unexpected commit author identity: $($unexpectedAuthors -join ', ')"
}

Write-Host "==> git remotes" -ForegroundColor Cyan
$githubHead = Get-RemoteHead "GitHub" "https://github.com/cxh04/Cron-Mbt.git"
$gitlinkHead = Get-RemoteHead "GitLink" "https://gitlink.org.cn/cxh0404/Cron-Mbt.git"
$githubTag = git ls-remote "https://github.com/cxh04/Cron-Mbt.git" "refs/tags/$tag^{}"
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($githubTag)) {
  throw "GitHub is missing $tag"
}
$gitlinkTag = git ls-remote "https://gitlink.org.cn/cxh0404/Cron-Mbt.git" "refs/tags/$tag^{}"
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($gitlinkTag)) {
  throw "GitLink is missing $tag"
}

Write-Host ""
Write-Host "Summary" -ForegroundColor Green
Write-Host "  version: $manifestVersion"
Write-Host "  commits: $commitCount"
Write-Host "  moonbit_loc: $loc"
Write-Host "  authors: $($authors -join ', ')"
Write-Host "  github_master: $githubHead"
Write-Host "  gitlink_master: $gitlinkHead"
Write-Host "  release_tag: $tag"

if (-not $SkipMooncakes) {
  Write-Check "moon publish --dry-run" { moon publish --dry-run }
}

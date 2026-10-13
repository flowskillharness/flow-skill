# Install the flow skill into every AI-harness skills dir on this machine (Windows PowerShell 7+).
#   pwsh install.ps1 global                     -> ~/.claude/skills/flow (always)
#                                                  + ~/.codex/skills/flow  (if ~/.codex/skills exists)
#                                                  + ~/.agents/skills/flow (if ~/.agents/skills exists)
#                                                  + Antigravity homes     (if ~/.gemini exists):
#                                                      ~/.gemini/antigravity-cli/skills/flow (CLI)
#                                                      ~/.gemini/config/skills/flow          (IDE)
#                                                  + OMP home              (if ~/.omp/agent/skills exists):
#                                                      ~/.omp/agent/skills/flow
#   pwsh install.ps1 global claude|codex|agents|antigravity|omp -> only that one harness
#   pwsh install.ps1 project [dir]              -> <dir|cwd>/.claude/skills/flow
#
# Safe transactional installation:
#   - Replaces destructive pre-deletion with atomic staging and swap.
#   - Raw path validation rejects symlinks, reparse points, and relative '..' traversals
#     BEFORE creating directories.
#   - In-place updates of existing directories require Python 3 (stdlib-only installer_helper.py)
#     to ensure atomic backup/promotion, strict conflict refusal, custom file preservation,
#     and receipt verification across both shell and PowerShell channels.
#     If Python is unavailable on an existing destination, the update fails loudly and the
#     original tree is left untouched.
#   - Fresh installs use the helper when Python is available (generating manifest-hashes.json);
#     otherwise they use native PowerShell staging with rename-backed empty-destination
#     preservation and automatic rollback on failure.
#   - Pipeline integrity: All subprocess stdout/stderr is captured or routed to host streams,
#     ensuring Install-To returns only the destination string without JSON pollution.
#   - Host disclosure: This Linux host does not have PowerShell installed. The script below has
#     been authored to match the specification and statically reviewed, but is not executed on
#     this Linux runner (no untested cross-OS parity claimed; Windows verification runs via CI).
#
# Re-run after any update to re-sync every harness (the repo is the single source of truth).
param(
  [ValidateSet('global','project')] [string]$Mode = 'global',
  [string]$Arg2 = ''
)
$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src  = Join-Path $Here 'skills/flow'
if (-not (Test-Path (Join-Path $Src 'SKILL.md'))) { Write-Error "skill source not found at $Src"; exit 1 }

$Helper = Join-Path $Src 'runner/installer_helper.py'
$UserHome = if ($env:HOME) { $env:HOME } elseif ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }

function Find-Python() {
  foreach ($cmd in @('python3', 'python')) {
    $c = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($c) {
      & $c.Source -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)" 2>$null >$null
      if ($LASTEXITCODE -eq 0) { return $c.Source }
    }
  }
  return $null
}

function Test-SafePath([string]$path, [string]$label) {
  if ([string]::IsNullOrWhiteSpace($path)) { throw "$label path is empty" }
  if ($path -match '(\\|/)\.\.(\\|/)|^\.\.(\\|/)|(\\|/)\.\.$|^\.\.$') {
    throw "$label path containing '..' relative traversal refused: $path"
  }
  $root = [System.IO.Path]::GetPathRoot($path)
  $rel = if ($root) { $path.Substring($root.Length) } else { $path }
  $curr = if ($root) { $root } else { (Get-Location).Path }
  $segments = $rel.Split([char[]]@('/','\'), [System.StringSplitOptions]::RemoveEmptyEntries)
  foreach ($seg in $segments) {
    $curr = [System.IO.Path]::Combine($curr, $seg)
    try {
      $item = Get-Item -LiteralPath $curr -Force -ErrorAction Stop
      if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        throw "$label symlink/reparse point component refused: $curr"
      }
    } catch [System.Management.Automation.ItemNotFoundException] {
      # Component does not exist yet (normal for destination tails)
    }
  }
}

function Test-SourceTree([string]$sourceRoot) {
  Test-SafePath $sourceRoot "source"
  $items = Get-ChildItem -LiteralPath $sourceRoot -Recurse -Force
  foreach ($item in $items) {
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
      throw "source tree contains symlink/reparse point which is refused: $($item.FullName)"
    }
  }
}

function Install-To([string]$dest) {
  Test-SafePath $dest "destination"
  $parent = Split-Path -Parent $dest

  $py = Find-Python
  $destExists = Test-Path -LiteralPath $dest
  $isNonEmpty = $false
  if ($destExists) {
    $items = Get-ChildItem -LiteralPath $dest -Force -ErrorAction SilentlyContinue
    if ($items -and $items.Count -gt 0) { $isNonEmpty = $true }
  }

  if ($isNonEmpty) {
    # In-place update requires the Python stdlib helper for full transaction safety
    if (-not $py) {
      Write-Error "updating an existing flow install requires Python 3 (ownership-receipt transaction); destination left untouched: $dest"
      exit 1
    }
    if (-not (Test-Path $Helper)) {
      Write-Error "installer helper missing at $Helper"
      exit 1
    }

    $helperOutput = & $py $Helper upgrade $Src $dest 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
      Write-Host $helperOutput
      Write-Error "update failed for $dest (exit code $exitCode)"
      exit $exitCode
    }
    Write-Host "installed flow -> $dest"
    return $dest
  } else {
    # Fresh install: use helper with receipt if Python is available
    if ($py -and (Test-Path $Helper)) {
      $helperOutput = & $py $Helper upgrade $Src $dest 2>&1
      $exitCode = $LASTEXITCODE
      if ($exitCode -ne 0) {
        Write-Host $helperOutput
        Write-Error "fresh install via helper failed for $dest (exit code $exitCode)"
        exit $exitCode
      }
      Write-Host "installed flow -> $dest"
      return $dest
    }

    # Native PowerShell fresh staging fallback (no Python)
    Test-SourceTree $Src

    if (-not (Test-Path -LiteralPath $parent)) {
      Test-SafePath $parent "destination parent"
      New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    $randSuffix = [System.IO.Path]::GetRandomFileName()
    $stage = Join-Path $parent (".flow-skill-stage-" + $randSuffix)
    if (Test-Path -LiteralPath $stage) { throw "staging collision at $stage" }

    $backupSlot = $null
    try {
      New-Item -ItemType Directory -Force -Path $stage | Out-Null
      Get-ChildItem -LiteralPath $Src -Force | Copy-Item -Destination $stage -Recurse -Force

      # Handle empty existing destination via rename-backup before promoting
      if (Test-Path -LiteralPath $dest) {
        $item = Get-Item -LiteralPath $dest -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
          throw "destination is a symlink/reparse point: $dest"
        }
        if (-not $item.PSIsContainer) {
          throw "destination exists and is not a directory: $dest"
        }
        $children = Get-ChildItem -LiteralPath $dest -Force
        if ($children -and $children.Count -gt 0) {
          throw "destination exists and is not empty: $dest"
        }

        $backupSlot = Join-Path $parent (".flow-skill-backup-" + [System.IO.Path]::GetRandomFileName())
        Move-Item -LiteralPath $dest -Destination $backupSlot
      }

      Move-Item -LiteralPath $stage -Destination $dest

      # Promotion succeeded: cleanup empty dir backup
      if ($backupSlot -and (Test-Path -LiteralPath $backupSlot)) {
        Remove-Item -LiteralPath $backupSlot -Recurse -Force -ErrorAction SilentlyContinue
        $backupSlot = $null
      }
    } catch {
      if (Test-Path -LiteralPath $stage) {
        Remove-Item -LiteralPath $stage -Recurse -Force -ErrorAction SilentlyContinue
      }
      if ($backupSlot -and (Test-Path -LiteralPath $backupSlot)) {
        if (-not (Test-Path -LiteralPath $dest)) {
          try {
            Move-Item -LiteralPath $backupSlot -Destination $dest -ErrorAction Stop
          } catch {
            Write-Error "promotion failed and rollback failed ($_); original destination preserved at '$backupSlot' (recover manually)"
            throw "promotion failed and rollback failed; original destination preserved at '$backupSlot'"
          }
        } else {
          Write-Error "promotion failed: destination remains occupied; original destination preserved at '$backupSlot' (recover manually)"
          throw "promotion failed: destination remains occupied; original destination preserved at '$backupSlot'"
        }
      }
      throw $_
    }

    Write-Host "NOTE: Python 3 not found - installed without ownership receipt; future in-place updates will refuse unknown file collisions."
    Write-Host "installed flow -> $dest"
    return $dest
  }
}

$RestartHints = @{
  claude      = 'Claude Code: type /flow'
  codex       = 'Codex CLI: type $flow (restart Codex once to load a new skill)'
  antigravity = 'Antigravity: restart/reload the IDE (or restart agy) to load the new skill, then type /flow'
  agents      = 'Agents home (~/.agents/skills/): restart/reload your tool if it does not auto-detect new skills'
  omp         = 'OMP: restart/reload your agent to load the new skill, then invoke flow'
}
function Get-DoneLine([string[]]$installed) {
  $hints = $installed | ForEach-Object { $RestartHints[$_] } | Where-Object { $_ }
  return "Done. " + ($hints -join '  |  ')
}
if ($MyInvocation.InvocationName -eq '.') {
  return
}

$last = $null
$installed = @()
if ($Mode -eq 'global') {
  $target = if ($Arg2 -ne '') { $Arg2 } else { 'all' }
  if ($target -eq 'all' -or $target -eq 'claude') {
    $last = Install-To (Join-Path $UserHome '.claude/skills/flow')
    $installed += 'claude'
  }
  if ($target -eq 'codex'  -or ($target -eq 'all' -and (Test-Path (Join-Path $UserHome '.codex/skills')))) {
    $last = Install-To (Join-Path $UserHome '.codex/skills/flow')
    $installed += 'codex'
  }
  if ($target -eq 'agents' -or ($target -eq 'all' -and (Test-Path (Join-Path $UserHome '.agents/skills')))) {
    $last = Install-To (Join-Path $UserHome '.agents/skills/flow')
    $installed += 'agents'
  }
  # antigravity (Gemini): same SKILL.md bundle; two global homes (CLI + IDE) under ~/.gemini
  if ($target -eq 'antigravity' -or ($target -eq 'all' -and (Test-Path (Join-Path $UserHome '.gemini')))) {
    $last = Install-To (Join-Path $UserHome '.gemini/antigravity-cli/skills/flow')   # agy CLI global
    $installed += 'antigravity'
    $last = Install-To (Join-Path $UserHome '.gemini/config/skills/flow')            # Antigravity IDE global
  }
  # omp: explicit target or autodetected only when ~/.omp/agent/skills exists (never bare ~/.omp)
  if ($target -eq 'omp' -or ($target -eq 'all' -and (Test-Path (Join-Path $UserHome '.omp/agent/skills')))) {
    $last = Install-To (Join-Path $UserHome '.omp/agent/skills/flow')
    $installed += 'omp'
  }
  if (-not $last) { Write-Error "unknown target '$target' (use claude|codex|agents|antigravity|omp|all)"; exit 1 }
} else {
  $dir = if ($Arg2 -ne '') { $Arg2 } else { (Get-Location).Path }
  $last = Install-To (Join-Path $dir '.claude/skills/flow')
  $installed += 'claude'
}

Write-Host ""
# flow's runner needs Git Bash; prefer it over WSL's System32\bash.exe (WSL can't see C:/ paths)
$bashExe = $null
foreach ($c in @("$env:ProgramFiles\Git\bin\bash.exe", "${env:ProgramFiles(x86)}\Git\bin\bash.exe", "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe")) {
  if (Test-Path $c) { $bashExe = $c; break }
}
if (-not $bashExe) {
  $g = Get-Command bash -ErrorAction SilentlyContinue
  if ($g -and $g.Source -notmatch 'System32[\\/]bash\.exe') { $bashExe = $g.Source }
}
if ($bashExe) {
  # forward-slash path so Git Bash doesn't strip Windows backslashes; doctor stays non-fatal (parity with bash `|| true`)
  $runner = (Join-Path $last 'runner/flow.sh') -replace '\\','/'
  try { & $bashExe $runner doctor } catch { Write-Warning "doctor reported issues (non-fatal): $_" }
} else {
  Write-Host "  bash: Git Bash not found - install Git for Windows so the gate runner can execute."
}
Write-Host ""
Write-Host (Get-DoneLine $installed)

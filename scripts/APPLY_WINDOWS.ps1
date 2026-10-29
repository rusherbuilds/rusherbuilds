# Safe, opt-in GitHub profile repository publisher.
# Preview: .\scripts\APPLY_WINDOWS.ps1 -DryRun
# Publish: .\scripts\APPLY_WINDOWS.ps1 (then type APPLY)
param([switch]$DryRun)
$ErrorActionPreference = 'Stop'
$UserName = 'rusherbuilds'
$RepoName = "$UserName/$UserName"
$Source = Split-Path -Parent $PSScriptRoot
$Managed = @('README.md', '.github', 'assets', 'docs', 'scripts', 'tests', 'START_HERE_AR.md', 'DEPLOY_COMMANDS_AR.md', 'LICENSE.md', '.gitignore')

function Invoke-Checked([string]$Command, [string[]]$Arguments) {
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed (exit $LASTEXITCODE)." }
}

function Stage-Package([string]$Clone) {
    foreach ($Item in $Managed) {
        $From = Join-Path $Source $Item
        if (Test-Path -LiteralPath $From -PathType Leaf) {
            Copy-Item -LiteralPath $From -Destination (Join-Path $Clone $Item) -Force
        } else {
            Get-ChildItem -LiteralPath $From -File -Recurse -Force | ForEach-Object {
                $Rel = $_.FullName.Substring($Source.Length).TrimStart('\', '/')
                $To = Join-Path $Clone $Rel
                New-Item -ItemType Directory -Path (Split-Path -Parent $To) -Force | Out-Null
                Copy-Item -LiteralPath $_.FullName -Destination $To -Force
            }
        }
    }
    Invoke-Checked -Command 'git' -Arguments (@('-C', $Clone, 'add', '--') + $Managed)
}

foreach ($Command in @('git','gh')) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) { throw "Install $Command before using this script." }
}
foreach ($Item in $Managed) {
    if (-not (Test-Path -LiteralPath (Join-Path $Source $Item))) { throw "Missing package entry: $Item" }
}

$ConnectedUser = (& gh api user --jq '.login' 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw "GitHub login required. Run: gh auth login -h github.com" }
if ($ConnectedUser -cne $UserName) {
    throw "Signed in as '$ConnectedUser', expected '$UserName'. Nothing changed. Switch accounts with gh auth switch."
}

# Only 404 means missing. Permission and network failures stop without creating anything.
$PriorErrorAction = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
try {
    $Visibility = (& gh api "repos/$RepoName" --jq '.visibility' 2>&1 | Out-String).Trim()
    $RepoLookupExit = $LASTEXITCODE
} finally {
    $ErrorActionPreference = $PriorErrorAction
}
$Exists = $false
if ($RepoLookupExit -eq 0) {
    $Exists = $true
    if ($Visibility -cne 'public') {
        throw "Existing repository is '$Visibility'. Change visibility manually if intended; no automatic visibility changes."
    }
} elseif ($Visibility -notmatch 'HTTP 404') {
    throw "Could not inspect $RepoName. $Visibility"
}

$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ('rusher-profile-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $TempDir | Out-Null
try {
    $Clone = Join-Path $TempDir 'repo'
    $OriginalReadmeTemp = Join-Path $TempDir 'original-README.md'
    Write-Host "Signed in as: $ConnectedUser" -ForegroundColor Cyan
    Write-Host "Target: https://github.com/$RepoName" -ForegroundColor Cyan
    Write-Host "Managed paths: $($Managed -join ', ')"
    Write-Host 'Other repositories/files will not be touched. No force pushes.'

    if ($Exists) {
        Invoke-Checked -Command 'git' -Arguments @('clone', "https://github.com/$RepoName.git", $Clone)
        if (Test-Path -LiteralPath (Join-Path $Clone 'README.md')) {
            Copy-Item -LiteralPath (Join-Path $Clone 'README.md') -Destination $OriginalReadmeTemp
        }
        Stage-Package $Clone
        Write-Host 'Staged change preview:'
        Invoke-Checked -Command 'git' -Arguments @('-C', $Clone, 'diff', '--cached', '--stat')
        & git -C $Clone diff --cached --quiet
        if ($LASTEXITCODE -eq 0) { Write-Host 'Already up to date.'; exit 0 }
        if ($LASTEXITCODE -ne 1) { throw 'Could not inspect staged changes.' }
    } else {
        Write-Host "Repository $RepoName does not exist; it will be created only after confirmation."
        Write-Host "New repository files: $($Managed -join ', ')"
    }

    if ($DryRun) { Write-Host 'DRY RUN COMPLETE: nothing published.' -ForegroundColor Green; exit 0 }
    $Answer = Read-Host "Type APPLY to create/update $RepoName"
    if ($Answer -cne 'APPLY') { Write-Host 'Cancelled. Nothing was published.'; exit 0 }

    if (-not $Exists) {
        Invoke-Checked -Command 'gh' -Arguments @('repo','create',$RepoName,'--public','--add-readme','--description','Animated GitHub profile and engineering portfolio')
        Invoke-Checked -Command 'git' -Arguments @('clone', "https://github.com/$RepoName.git", $Clone)
        Stage-Package $Clone
    } elseif (Test-Path -LiteralPath $OriginalReadmeTemp) {
        $BackupDir = Join-Path $Source 'backups'
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        $Backup = Join-Path $BackupDir ('README_BACKUP_' + (Get-Date -Format 'yyyyMMdd_HHmmss') + '_' + [guid]::NewGuid().ToString('N') + '.md')
        Copy-Item -LiteralPath $OriginalReadmeTemp -Destination $Backup
        Write-Host "Original README saved locally: $Backup"
    }

    & git -C $Clone diff --cached --quiet
    if ($LASTEXITCODE -eq 0) { Write-Host 'Already up to date.'; exit 0 }
    if ($LASTEXITCODE -ne 1) { throw 'Could not inspect staged changes.' }
    $GhUserId = (& gh api user --jq '.id' 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $GhUserId -notmatch '^[0-9]+$') { throw 'Could not verify GitHub numeric user ID.' }
    Invoke-Checked -Command 'git' -Arguments @('-C', $Clone, 'config', 'user.name', $ConnectedUser)
    Invoke-Checked -Command 'git' -Arguments @('-C', $Clone, 'config', 'user.email', "$GhUserId+$ConnectedUser@users.noreply.github.com")
    Invoke-Checked -Command 'git' -Arguments @('-C', $Clone, 'commit', '-m', 'Enhance GitHub profile and portfolio')
    Invoke-Checked -Command 'git' -Arguments @('-C', $Clone, 'push', 'origin', 'HEAD')
    Write-Host "Published: https://github.com/$UserName" -ForegroundColor Green
    Write-Host 'Next: Run Build contribution arcade in Actions; enable GitHub Pages on default branch /docs.'
} finally {
    if (Test-Path -LiteralPath $TempDir) { Remove-Item -LiteralPath $TempDir -Recurse -Force }
}

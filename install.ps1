<#
.SYNOPSIS
    Installs or updates the Cookie Monster PowerShell profile fragment.

.DESCRIPTION
    Downloads or copies the CookieMonster.profile.ps1 fragment and injects a
    dot-source block into the current user's PowerShell profile so that the
    cookie command and random encounter hook are available in every session.

    Three modes are supported:
      InstallLocal  – copy the fragment from this repo (default)
      UpdateNow     – download the latest GitHub release into the local cache
      AutoInstall   – download and immediately install the latest GitHub release

.PARAMETER SourcePath
    Path to the CookieMonster.profile.ps1 fragment to install locally.
    Defaults to the file alongside this script.

.PARAMETER TargetProfilePath
    Destination PowerShell profile to inject the dot-source block into.
    Defaults to $PROFILE (CurrentUserCurrentHost).

.PARAMETER TargetFragmentPath
    Where to copy the profile fragment on disk.
    Defaults to a sibling file next to the target profile.

.PARAMETER Repository
    GitHub repository slug used when downloading a release.
    Defaults to ilim-cell/cookie-monster.

.PARAMETER CachePath
    Local directory used to store downloaded release archives.
    Defaults to ~/.cache/cookie-monster.

.PARAMETER UpdateNow
    Download the latest release into the cache without installing it.

.PARAMETER AutoInstall
    Download the latest release and install it immediately.

.PARAMETER Force
    Overwrite existing cached downloads and profile backups.

.EXAMPLE
    .\install.ps1
    Runs the interactive installer menu (InstallLocal is the default choice).

.EXAMPLE
    .\install.ps1 -AutoInstall
    Downloads and installs the latest release non-interactively.

.EXAMPLE
    .\install.ps1 -UpdateNow
    Downloads the latest release into the cache for later use.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SourcePath = (Join-Path $PSScriptRoot 'CookieMonster.profile.ps1'),
    [string]$TargetProfilePath,
    [string]$TargetFragmentPath,
    [string]$Repository = 'ilim-cell/cookie-monster',
    [string]$CachePath,
    [switch]$UpdateNow,
    [switch]$AutoInstall,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-CookieMonsterTargetProfilePath {
    if ($TargetProfilePath) {
        return $TargetProfilePath
    }

    if ($PROFILE -is [string] -and -not [string]::IsNullOrWhiteSpace($PROFILE)) {
        return $PROFILE
    }

    if ($PROFILE.CurrentUserCurrentHost) {
        return $PROFILE.CurrentUserCurrentHost
    }

    return (Join-Path $HOME '.config/powershell/Microsoft.PowerShell_profile.ps1')
}

function Get-CookieMonsterTargetFragmentPath {
    if ($TargetFragmentPath) {
        return $TargetFragmentPath
    }

    return (Join-Path (Split-Path -Parent (Get-CookieMonsterTargetProfilePath)) 'CookieMonster.profile.ps1')
}

function Get-CookieMonsterCachePath {
    if ($CachePath) {
        return $CachePath
    }

    return (Join-Path $HOME '.cache/cookie-monster')
}

function New-CookieMonsterDirectory {
    param([Parameter(Mandatory)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Test-CookieMonsterInteractiveHost {
    return ([Environment]::UserInteractive -and $Host.Name -ne 'ServerRemoteHost')
}

function Show-CookieMonsterArt {
    param(
        [string]$Title = 'COOKIE MONSTER INSTALLER',
        [string]$Subtitle = 'Cross-platform update and install mode'
    )

    $width = 72
    $inner = $width - 2
    $line = '=' * $inner

    Write-Host "+$line+" -ForegroundColor Blue
    Write-Host ('|' + (' ' + $Title).PadRight($inner) + '|') -ForegroundColor Cyan
    Write-Host ('|' + (' ' + $Subtitle).PadRight($inner) + '|') -ForegroundColor DarkCyan
    Write-Host ('|' + (' ' * $inner) + '|') -ForegroundColor Blue
    Write-Host ('|' + '  .-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-.  '.PadRight($inner) + '|') -ForegroundColor Yellow
    Write-Host ('|' + '  ( Cookie Monster is preparing your install experience... )  '.PadRight($inner) + '|') -ForegroundColor Yellow
    Write-Host ('|' + '  `-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-` '.PadRight($inner) + '|') -ForegroundColor Yellow
    Write-Host ('|' + (' ' * $inner) + '|') -ForegroundColor Blue
    Write-Host "+$line+" -ForegroundColor Blue
}

function Show-CookieMonsterSpinner {
    param(
        [Parameter(Mandatory)][string]$Message,
        [int]$DurationMilliseconds = 1200
    )

    $frames = @('[. ]','[o ]','[oo]','[ o]','[  ]')
    $frameDelay = [Math]::Max(80, [int]($DurationMilliseconds / $frames.Count))

    if (-not (Test-CookieMonsterInteractiveHost)) {
        Write-Host $Message -ForegroundColor Yellow
        return
    }

    for ($i = 0; $i -lt $frames.Count; $i++) {
        Write-Host -NoNewline ("`r{0} {1}" -f $frames[$i], $Message.PadRight(52))
        Start-Sleep -Milliseconds $frameDelay
    }
    Write-Host ("`r" + $Message.PadRight($Message.Length + 4)) -ForegroundColor Green
}

function Show-CookieMonsterInstallerMenu {
    if (-not (Test-CookieMonsterInteractiveHost)) {
        return 'InstallLocal'
    }

    Show-CookieMonsterArt
    Write-Host ''
    Write-Host 'Choose what Cookie Monster should do:' -ForegroundColor Gray
    Write-Host '  [1] Install from this repo copy' -ForegroundColor Cyan
    Write-Host '  [2] Update now only (download to cache)' -ForegroundColor Yellow
    Write-Host '  [3] Automatically install latest release' -ForegroundColor Green
    Write-Host '  [4] Exit' -ForegroundColor DarkGray
    Write-Host ''
    $choice = Read-Host 'Enter choice (1-4)'

    switch ($choice.Trim()) {
        '1' { return 'InstallLocal' }
        '2' { return 'UpdateNow' }
        '3' { return 'AutoInstall' }
        default { return 'Exit' }
    }
}

function Get-CookieMonsterLatestRelease {
    param([Parameter(Mandatory)][string]$RepositoryName)

    $uri = "https://api.github.com/repos/$RepositoryName/releases/latest"
    $headers = @{ 'User-Agent' = 'cookie-monster-installer' }
    Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
}

function Save-CookieMonsterReleaseZip {
    param(
        [Parameter(Mandatory)]$Release,
        [Parameter(Mandatory)][string]$DestinationDirectory
    )

    New-CookieMonsterDirectory -Path $DestinationDirectory

    $asset = $Release.assets | Where-Object { $_.name -eq 'cookie-monster.zip' } | Select-Object -First 1
    if (-not $asset) {
        throw 'The latest release does not contain a cookie-monster.zip asset.'
    }

    $zipPath = Join-Path $DestinationDirectory $asset.name
    if (-not (Test-Path -LiteralPath $zipPath) -or $Force) {
        Show-CookieMonsterSpinner -Message 'Downloading latest release into cache...' -DurationMilliseconds 1400
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath
    }

    [PSCustomObject]@{
        ZipPath = $zipPath
        TagName = $Release.tag_name
        Version = $Release.tag_name
    }
}

function Expand-CookieMonsterReleaseZip {
    param(
        [Parameter(Mandatory)][string]$ZipPath,
        [Parameter(Mandatory)][string]$DestinationDirectory
    )

    if (-not (Test-Path -LiteralPath $ZipPath)) {
        throw "Release archive not found: $ZipPath"
    }

    if (Test-Path -LiteralPath $DestinationDirectory) {
        Remove-Item -LiteralPath $DestinationDirectory -Recurse -Force
    }

    New-CookieMonsterDirectory -Path $DestinationDirectory
    Show-CookieMonsterSpinner -Message 'Expanding release archive...' -DurationMilliseconds 1000
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $DestinationDirectory -Force

    $fragment = Get-ChildItem -LiteralPath $DestinationDirectory -Recurse -File -Filter 'CookieMonster.profile.ps1' | Select-Object -First 1
    if (-not $fragment) {
        throw 'The release archive did not contain CookieMonster.profile.ps1.'
    }

    return $fragment.FullName
}

function Install-CookieMonsterProfileFragment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$TargetProfile,
        [Parameter(Mandatory)][string]$TargetFragment
    )

    New-CookieMonsterDirectory -Path (Split-Path -Parent $TargetProfile)
    New-CookieMonsterDirectory -Path (Split-Path -Parent $TargetFragment)

    if (Test-Path -LiteralPath $TargetProfile) {
        $backupPath = "$TargetProfile.bak"
        if (-not (Test-Path -LiteralPath $backupPath) -or $Force) {
            Copy-Item -LiteralPath $TargetProfile -Destination $backupPath -Force
        }
    } else {
        New-Item -ItemType File -Path $TargetProfile -Force | Out-Null
    }

    Copy-Item -LiteralPath $Source -Destination $TargetFragment -Force

    $markerStart = '# >>> cookie-monster >>>'
    $markerEnd = '# <<< cookie-monster <<<'
    $dotSourceLine = ". '$TargetFragment'"
    $block = @(
        $markerStart
        $dotSourceLine
        $markerEnd
    ) -join [Environment]::NewLine

    $profileContent = Get-Content -LiteralPath $TargetProfile -Raw
    if ([string]::IsNullOrWhiteSpace($profileContent)) {
        $profileContent = ''
    }

    if ($profileContent -match [regex]::Escape($markerStart) -and $profileContent -match [regex]::Escape($markerEnd)) {
        $updated = [regex]::Replace(
            $profileContent,
            [regex]::Escape($markerStart) + '.*?' + [regex]::Escape($markerEnd),
            [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block },
            [System.Text.RegularExpressions.RegexOptions]::Singleline
        )
    } else {
        $separator = if ([string]::IsNullOrWhiteSpace($profileContent)) { '' } else { [Environment]::NewLine + [Environment]::NewLine }
        $updated = $profileContent + $separator + $block + [Environment]::NewLine
    }

    if ($PSCmdlet.ShouldProcess($TargetProfile, 'Install Cookie Monster profile fragment')) {
        Set-Content -LiteralPath $TargetProfile -Value $updated -Encoding utf8
    }
}

function Write-CookieMonsterBanner {
    param([string]$Message)

    Write-Host $Message -ForegroundColor Yellow
}

$targetProfile = Get-CookieMonsterTargetProfilePath
$targetFragment = Get-CookieMonsterTargetFragmentPath
$cacheRoot = Get-CookieMonsterCachePath
$stageRoot = Join-Path $cacheRoot 'stage'
$stagedFragmentPath = Join-Path $stageRoot 'CookieMonster.profile.ps1'
$downloadRoot = Join-Path $cacheRoot 'downloads'

New-CookieMonsterDirectory -Path $cacheRoot

$mode = $null
if (-not $UpdateNow -and -not $AutoInstall) {
    $mode = Show-CookieMonsterInstallerMenu
    if ($mode -eq 'Exit') {
        Write-Host 'Installer canceled.' -ForegroundColor DarkGray
        return
    }
} elseif ($AutoInstall) {
    $mode = 'AutoInstall'
} elseif ($UpdateNow) {
    $mode = 'UpdateNow'
} else {
    $mode = 'InstallLocal'
}

Show-CookieMonsterSpinner -Message 'Preparing Cookie Monster install...' -DurationMilliseconds 1000

if (Test-Path -LiteralPath $SourcePath) {
    $localSourcePath = $SourcePath
} else {
    $localSourcePath = $null
}

$installSourcePath = $null

if ($mode -in @('UpdateNow', 'AutoInstall')) {
    Show-CookieMonsterArt -Title 'COOKIE MONSTER UPDATE ENGINE' -Subtitle 'Downloading from GitHub Releases'
    Show-CookieMonsterSpinner -Message "Fetching latest Cookie Monster release from GitHub ($Repository)..." -DurationMilliseconds 1200
    $release = Get-CookieMonsterLatestRelease -RepositoryName $Repository
    $cachedRelease = Save-CookieMonsterReleaseZip -Release $release -DestinationDirectory $downloadRoot
    $installSourcePath = Expand-CookieMonsterReleaseZip -ZipPath $cachedRelease.ZipPath -DestinationDirectory $stageRoot

    $meta = [PSCustomObject]@{
        Repository = $Repository
        TagName = $cachedRelease.TagName
        ZipPath = $cachedRelease.ZipPath
        CachedAt = (Get-Date).ToString('o')
    }
    $meta | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $cacheRoot 'latest.json') -Encoding utf8

    if ($mode -eq 'UpdateNow') {
        Write-Host "Cached latest release at $($cachedRelease.ZipPath)" -ForegroundColor Green
        Write-Host "Run install.ps1 -AutoInstall to install it now." -ForegroundColor Gray
        return
    }
} elseif ($mode -eq 'InstallLocal' -and $localSourcePath) {
    $installSourcePath = $localSourcePath
} elseif ($mode -eq 'AutoInstall' -and (Test-Path -LiteralPath $stagedFragmentPath)) {
    $installSourcePath = $stagedFragmentPath
}

if (-not $installSourcePath) {
    throw 'No install source was found. Provide a local SourcePath or run with -UpdateNow / -AutoInstall.'
}

Install-CookieMonsterProfileFragment -Source $installSourcePath -TargetProfile $targetProfile -TargetFragment $targetFragment

Show-CookieMonsterSpinner -Message 'Finalizing profile integration...' -DurationMilliseconds 900
Write-Host ('Installed Cookie Monster profile fragment to ' + $targetFragment) -ForegroundColor Green
Write-Host ('Profile updated at ' + $targetProfile) -ForegroundColor Green

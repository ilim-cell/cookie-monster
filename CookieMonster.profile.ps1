# Cookie Monster profile fragment
# Extracted and trimmed from the user's PowerShell profile so it can be installed cleanly.
# PSScriptAnalyzer disable PSUseApprovedVerbs, PSUseDeclaredVarsMoreThanAssignments

if ($null -eq $global:CookieMonsterEnabled) { $global:CookieMonsterEnabled = $false }
if ($null -eq $global:CookieMonsterActive)  { $global:CookieMonsterActive  = $false }

if ($null -eq $global:CookieEncounters)   { $global:CookieEncounters   = 0 }
if ($null -eq $global:CookiesEaten)        { $global:CookiesEaten        = 0 }
if ($null -eq $global:CookieRefusals)      { $global:CookieRefusals      = 0 }
if ($null -eq $global:BakedCookies)        { $global:BakedCookies        = 0 }
if ($null -eq $global:OatmealCookies)      { $global:OatmealCookies      = 0 }
if ($null -eq $global:GlitterCookies)      { $global:GlitterCookies      = 0 }
if ($null -eq $global:BurntCookies)        { $global:BurntCookies        = 0 }
if ($null -eq $global:RawDoughCookies)     { $global:RawDoughCookies     = 0 }
if ($null -eq $global:JunkCookies)         { $global:JunkCookies         = 0 }
if ($null -eq $global:GlitchCookies)       { $global:GlitchCookies       = 0 }
if ($null -eq $global:CustomCookies)       { $global:CustomCookies       = @() }

if ($null -eq $global:OatmealRaisintricked) { $global:OatmealRaisintricked = 0 }
if ($null -eq $global:PerfectBakesCount)    { $global:PerfectBakesCount    = 0 }
if ($null -eq $global:GlitterBakesCount)    { $global:GlitterBakesCount    = 0 }
if ($null -eq $global:BurntBakesCount)      { $global:BurntBakesCount      = 0 }
if ($null -eq $global:GlitterFedCount)      { $global:GlitterFedCount      = 0 }
if ($null -eq $global:SudoOatmealFed)       { $global:SudoOatmealFed       = 0 }
if ($null -eq $global:SudoDefianceCount)    { $global:SudoDefianceCount    = 0 }
if ($null -eq $global:EscapeBypassCaughts)   { $global:EscapeBypassCaughts   = 0 }
if ($null -eq $global:GlitchesTriggered)    { $global:GlitchesTriggered    = 0 }
if ($null -eq $global:TimeoutFailures)      { $global:TimeoutFailures      = 0 }

$script:CookieSettingsPath = Join-Path $HOME '.cookie_settings.json'
$script:CookieLockPath = Join-Path $HOME '.cookie_escaped_lock'

if ($null -eq $global:CookieSettings) {
    $global:CookieSettings = [ordered]@{
        EncounterChance = 5
        BeepsEnabled    = $true
        MonsterName     = 'Cookie Monster'
    }
}

if (Test-Path -LiteralPath $script:CookieSettingsPath) {
    try {
        $saved = Get-Content -LiteralPath $script:CookieSettingsPath -Raw | ConvertFrom-Json
        if ($null -ne $saved.EncounterChance) { $global:CookieSettings.EncounterChance = [int]$saved.EncounterChance }
        if ($null -ne $saved.BeepsEnabled)    { $global:CookieSettings.BeepsEnabled    = [bool]$saved.BeepsEnabled }
        if ($null -ne $saved.MonsterName)     { $global:CookieSettings.MonsterName     = [string]$saved.MonsterName }
    } catch {
        # Ignore corrupted settings and fall back to defaults.
    }
}

function Save-CookieSettings {
    try {
        $global:CookieSettings | ConvertTo-Json | Set-Content -LiteralPath $script:CookieSettingsPath -Encoding utf8
    } catch {
    }
}

function Invoke-CookieBeep {
    param(
        [int]$Frequency,
        [int]$Duration
    )

    if ($global:CookieSettings.BeepsEnabled -and $IsWindows) {
        [Console]::Beep($Frequency, $Duration)
    }
}

function Read-CookiePrompt {
    param(
        [int]$TimeoutSeconds = 0
    )

    if (-not $IsWindows -or $TimeoutSeconds -le 0) {
        return (Read-Host)
    }

    $cutoffTime = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $cutoffTime) {
        if ([Console]::KeyAvailable) {
            return (Read-Host)
        }
        Start-Sleep -Milliseconds 50
    }

    return '___TIMEOUT___'
}

function Start-BakingAnimation {
    Write-Host ''
    Write-Host 'Cookie Monster baking lab' -ForegroundColor Yellow
    Write-Host '1) Chocolate chip' -ForegroundColor Gray
    Write-Host '2) Oatmeal raisin' -ForegroundColor Gray
    Write-Host '3) Glitter cookie' -ForegroundColor Gray
    Write-Host -NoNewline 'Choose a cookie type (1-3): ' -ForegroundColor Cyan
    $choice = Read-CookiePrompt

    switch ($choice.Trim()) {
        '1' {
            $global:BakedCookies++
            $global:PerfectBakesCount++
            Write-Host 'Baked a perfect chocolate chip cookie.' -ForegroundColor Green
        }
        '2' {
            $global:OatmealCookies++
            Write-Host 'Baked an oatmeal raisin cookie.' -ForegroundColor Magenta
        }
        '3' {
            $global:GlitterCookies++
            $global:GlitterBakesCount++
            Write-Host 'Baked a glitter cookie.' -ForegroundColor Cyan
        }
        default {
            $global:BurntCookies++
            $global:BurntBakesCount++
            Write-Host 'The oven won. You got a burnt cookie.' -ForegroundColor Red
        }
    }
}

function Invoke-GlitchScreenAnimation {
    $global:GlitchesTriggered++

    if (-not $IsWindows) {
        Write-Host 'GLITCH COOKIE ACTIVATED' -ForegroundColor Cyan
        return
    }

    $oldFg = [Console]::ForegroundColor
    $oldBg = [Console]::BackgroundColor
    try {
        Clear-Host
        [Console]::ForegroundColor = 'Cyan'
        Write-Host 'GLITCH COOKIE ACTIVATED'
        [Console]::ForegroundColor = 'Magenta'
        Write-Host '010101 COOKIE MONSTER 010101'
    } finally {
        [Console]::ForegroundColor = $oldFg
        [Console]::BackgroundColor = $oldBg
    }
}

function Show-CookieScoreboard {
    Write-Host ''
    Write-Host 'COOKIE MONSTER SCOREBOARD' -ForegroundColor Yellow
    Write-Host "Encounters: $global:CookieEncounters"
    Write-Host "Cookies Eaten: $global:CookiesEaten"
    Write-Host "Refusals: $global:CookieRefusals"
    Write-Host "Baked Cookies: $global:BakedCookies"
    Write-Host "Oatmeal Cookies: $global:OatmealCookies"
    Write-Host "Glitter Cookies: $global:GlitterCookies"
    Write-Host "Burnt Cookies: $global:BurntCookies"
    Write-Host "Raw Dough: $global:RawDoughCookies"
    Write-Host "Junk Cookies: $global:JunkCookies"
    Write-Host "Glitch Cookies: $global:GlitchCookies"
    Write-Host "Custom Cookies: $($global:CustomCookies.Count)"
}

function Show-CookieSettingsMenu {
    $done = $false
    while (-not $done) {
        Write-Host ''
        Write-Host "Cookie Monster settings for $($global:CookieSettings.MonsterName)" -ForegroundColor Yellow
        Write-Host '1) Change encounter chance'
        Write-Host '2) Toggle beep sounds'
        Write-Host '3) Change monster name'
        Write-Host '4) Reset scoreboards'
        Write-Host '5) Exit'
        Write-Host -NoNewline 'Choose (1-5): ' -ForegroundColor Cyan
        $choice = Read-CookiePrompt

        switch ($choice.Trim()) {
            '1' {
                Write-Host -NoNewline 'New encounter chance (1-100): ' -ForegroundColor Cyan
                $newChance = Read-CookiePrompt
                if ($newChance -as [int] -and [int]$newChance -ge 1 -and [int]$newChance -le 100) {
                    $global:CookieSettings.EncounterChance = [int]$newChance
                    Save-CookieSettings
                }
            }
            '2' {
                $global:CookieSettings.BeepsEnabled = -not $global:CookieSettings.BeepsEnabled
                Save-CookieSettings
            }
            '3' {
                Write-Host -NoNewline 'New monster name: ' -ForegroundColor Cyan
                $newName = Read-CookiePrompt
                if (-not [string]::IsNullOrWhiteSpace($newName)) {
                    $global:CookieSettings.MonsterName = $newName.Trim()
                    Save-CookieSettings
                }
            }
            '4' {
                $global:CookieEncounters = 0
                $global:CookiesEaten = 0
                $global:CookieRefusals = 0
                $global:BakedCookies = 0
                $global:OatmealCookies = 0
                $global:GlitterCookies = 0
                $global:BurntCookies = 0
                $global:RawDoughCookies = 0
                $global:JunkCookies = 0
                $global:GlitchCookies = 0
                $global:CustomCookies = @()
                $global:OatmealRaisintricked = 0
                $global:PerfectBakesCount = 0
                $global:GlitterBakesCount = 0
                $global:BurntBakesCount = 0
                $global:GlitterFedCount = 0
                $global:SudoOatmealFed = 0
                $global:SudoDefianceCount = 0
                $global:EscapeBypassCaughts = 0
                $global:GlitchesTriggered = 0
                $global:TimeoutFailures = 0
            }
            '5' {
                $done = $true
            }
        }
    }
}

function Show-CookieHelp {
    Write-Host ''
    Write-Host 'cookie' -ForegroundColor Yellow
    Write-Host '  Launch the Cookie Monster.'
    Write-Host 'cookie --on' -ForegroundColor Yellow
    Write-Host '  Enable random encounters.'
    Write-Host 'cookie --off' -ForegroundColor Yellow
    Write-Host '  Disable random encounters.'
    Write-Host 'cookie --toggle' -ForegroundColor Yellow
    Write-Host '  Toggle random encounters.'
    Write-Host 'cookie --bake' -ForegroundColor Yellow
    Write-Host '  Bake a cookie batch.'
    Write-Host 'cookie --scoreboard' -ForegroundColor Yellow
    Write-Host '  View counters and achievements.'
    Write-Host 'cookie --settings' -ForegroundColor Yellow
    Write-Host '  Update preferences.'
    Write-Host 'cookie --help' -ForegroundColor Yellow
    Write-Host '  Show this help.'
}

function Start-CookieMonster {
    [CmdletBinding()]
    param(
        [switch]$BypassedEscaped
    )

    $isInteractive = [Environment]::UserInteractive -and ($Host.Name -eq 'ConsoleHost' -or $Host.Name -eq 'Visual Studio Code Host')
    if (-not $isInteractive) {
        return
    }

    $global:CookieMonsterActive = $true
    $global:CookieEncounters++

    try {
        Clear-Host
        Write-Host 'COOKIE MONSTER WANTS A COOKIE' -ForegroundColor Blue
        if ($BypassedEscaped) {
            Write-Host 'Escape bypass detected.' -ForegroundColor Red
        }

        $timerSeconds = 30
        if ($BypassedEscaped) {
            $timerSeconds = 15
        }

        $satisfied = $false
        while (-not $satisfied) {
            Write-Host ''
            Write-Host ('Give me a cookie, please. Timer is ' + $timerSeconds + ' seconds.') -ForegroundColor Cyan
            Write-Host "Try: cookie, feed, trick, magic, glitch, burn, dough, plead, no" -ForegroundColor Gray
            Write-Host -NoNewline 'COOKIE: ' -ForegroundColor Cyan
            $replyText = Read-CookiePrompt -TimeoutSeconds $timerSeconds
            if ($null -eq $replyText) {
                $cleanReply = ''
            } else {
                $cleanReply = $replyText.Trim().ToLower()
            }

            if ($cleanReply -eq '___timeout___') {
                $global:CookieRefusals++
                $global:TimeoutFailures++
                Write-Host 'Too slow! The monster is impatient.' -ForegroundColor Red
                continue
            }

            switch -Regex ($cleanReply) {
                '^cookie(s)?$|^chocolate chip$|^oreo$' {
                    $global:CookiesEaten++
                    $satisfied = $true
                }
                '^feed$' {
                    if ($global:BakedCookies -gt 0) {
                        $global:BakedCookies--
                        $global:CookiesEaten++
                        $satisfied = $true
                    } else {
                        $global:CookieRefusals++
                        Write-Host 'No baked cookies in inventory.' -ForegroundColor Red
                    }
                }
                '^trick$' {
                    if ($global:OatmealCookies -gt 0) {
                        $global:OatmealCookies--
                        $global:CookiesEaten++
                        $global:OatmealRaisintricked++
                        $satisfied = $true
                    } else {
                        $global:CookieRefusals++
                    }
                }
                '^magic$' {
                    if ($global:GlitterCookies -gt 0) {
                        $global:GlitterCookies--
                        $global:CookiesEaten++
                        $global:GlitterFedCount++
                        $satisfied = $true
                    } else {
                        $global:CookieRefusals++
                    }
                }
                '^glitch$' {
                    if ($global:GlitchCookies -gt 0) {
                        $global:GlitchCookies--
                        $global:CookiesEaten++
                        Invoke-GlitchScreenAnimation
                        $satisfied = $true
                    } else {
                        $global:CookieRefusals++
                    }
                }
                '^burn$' {
                    if ($global:BurntCookies -gt 0) {
                        $global:BurntCookies--
                        $global:CookieRefusals++
                    } else {
                        $global:CookieRefusals++
                    }
                }
                '^dough$|^junk$' {
                    $global:CookieRefusals++
                }
                '^plead$|^please$|^mercy$|^sorry$' {
                    if ($global:CookieRefusals -lt 3) {
                        $global:CookiesEaten++
                        $satisfied = $true
                    } else {
                        $global:CookieRefusals++
                    }
                }
                '^no$' {
                    $global:CookieRefusals++
                    Invoke-CookieBeep 900 100
                }
                default {
                    $global:CookieRefusals++
                    Write-Host "Try again, $($global:CookieSettings.MonsterName) is still hungry." -ForegroundColor Yellow
                }
            }
        }

        Write-Host ''
        Write-Host 'Om nom nom.' -ForegroundColor Green
    } finally {
        $global:CookieMonsterActive = $false
    }
}

function cookie {
    param(
        [Parameter(Position = 0)]
        [string]$Action
    )

    switch ($Action) {
        '--on' { $global:CookieMonsterEnabled = $true }
        '--off' { $global:CookieMonsterEnabled = $false }
        '--toggle' { $global:CookieMonsterEnabled = -not $global:CookieMonsterEnabled }
        '--scoreboard' { Show-CookieScoreboard }
        '--bake' { Start-BakingAnimation }
        '--settings' { Show-CookieSettingsMenu }
        '--help' { Show-CookieHelp }
        default { Start-CookieMonster }
    }
}

if (-not $script:CookieMonsterOriginalPrompt) {
    if (Get-Command -Name prompt -ErrorAction SilentlyContinue) {
        $script:CookieMonsterOriginalPrompt = $function:prompt
    } else {
        $script:CookieMonsterOriginalPrompt = { "PS $($executionContext.SessionState.Path.CurrentLocation)> " }
    }
}

function prompt {
    $promptText = & $script:CookieMonsterOriginalPrompt
    if ($global:CookieMonsterEnabled) {
        $roll = Get-Random -Minimum 1 -Maximum 101
        if ($roll -le $global:CookieSettings.EncounterChance) {
            Start-CookieMonster
        }
    }

    return $promptText
}

if ($env:CI -ne 'true') {
    Write-Host ''
    Write-Host 'Cookie Monster profile fragment loaded.' -ForegroundColor Green
    Write-Host "Use cookie --help for commands, or cookie --on to enable random encounters." -ForegroundColor Gray
}

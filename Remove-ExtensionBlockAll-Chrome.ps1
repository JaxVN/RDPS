#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Remove the "block all extensions" policy from Google Chrome.

.DESCRIPTION
    Removes the ExtensionInstallBlocklist wildcard entry that prevents
    all extensions from being installed in Google Chrome.
    After removal, Chrome returns to default behaviour (extensions allowed).

.NOTES
    Version     : 1.0.0
    Created     : 2026-03-30
    Browsers    : Google Chrome
    Registry    : HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist
    Source      : https://chromeenterprise.google/policies/#ExtensionInstallBlocklist
    Pair script : Set-ExtensionBlockAll-Chrome.ps1

.EXAMPLE
    .\Remove-ExtensionBlockAll-Chrome.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Config ────────────────────────────────────────────────────────────────────
$RegPath  = 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist'
$LogFile  = "$env:ProgramData\PCS\Logs\Remove-ExtensionBlockAll-Chrome.log"

# ── Helpers ───────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message, [ValidateSet('INFO','WARN','ERROR')]$Level = 'INFO')
    $ts   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Level] $Message"
    Write-Host $line
    $null = New-Item -ItemType Directory -Force -Path (Split-Path $LogFile)
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

# ── Main ──────────────────────────────────────────────────────────────────────
try {
    Write-Log "Starting Remove-ExtensionBlockAll-Chrome"

    if (-not (Test-Path $RegPath)) {
        Write-Log "Registry path does not exist — nothing to remove" -Level 'WARN'
        exit 0
    }

    # Remove the wildcard entry
    $prop = Get-ItemProperty -Path $RegPath -Name '1' -ErrorAction SilentlyContinue
    if ($prop) {
        Remove-ItemProperty -Path $RegPath -Name '1' -Force
        Write-Log "Removed ExtensionInstallBlocklist[1] = *"
    } else {
        Write-Log "Value '1' not found — nothing to remove" -Level 'WARN'
    }

    # If the key is now empty, remove it entirely to leave no policy residue
    $remaining = Get-Item -Path $RegPath -ErrorAction SilentlyContinue
    if ($remaining -and ($remaining.ValueCount -eq 0)) {
        Remove-Item -Path $RegPath -Force
        Write-Log "Removed empty registry key: $RegPath"
    }

    Write-Log "Remove-ExtensionBlockAll-Chrome completed successfully"
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level 'ERROR'
    exit 1
}

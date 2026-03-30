#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Block all Chrome extensions from being installed.

.DESCRIPTION
    Sets ExtensionInstallBlocklist policy with value "*" to prevent
    any extension from being installed in Google Chrome.
    Users will see a blocked message when attempting to install.

.NOTES
    Version     : 1.0.0
    Created     : 2026-03-30
    Browsers    : Google Chrome
    Registry    : HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist
    Source      : https://chromeenterprise.google/policies/#ExtensionInstallBlocklist
    Pair script : Remove-ExtensionBlockAll-Chrome.ps1

.EXAMPLE
    .\Set-ExtensionBlockAll-Chrome.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Config ────────────────────────────────────────────────────────────────────
$RegPath  = 'HKLM:\SOFTWARE\Policies\Google\Chrome\ExtensionInstallBlocklist'
$LogFile  = "$env:ProgramData\PCS\Logs\Set-ExtensionBlockAll-Chrome.log"

# ── Helpers ───────────────────────────────────────────────────────────────────
function Write-Log {
    param([string]$Message, [ValidateSet('INFO','WARN','ERROR')]$Level = 'INFO')
    $ts   = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$ts] [$Level] $Message"
    Write-Host $line
    $null = New-Item -ItemType Directory -Force -Path (Split-Path $LogFile)
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
}

function Ensure-RegistryPath {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
        Write-Log "Created registry path: $Path"
    }
}

# ── Main ──────────────────────────────────────────────────────────────────────
try {
    Write-Log "Starting Set-ExtensionBlockAll-Chrome"

    Ensure-RegistryPath -Path $RegPath

    # Value name "1" = first entry in the blocklist array
    # Value "*" = block ALL extensions
    Set-ItemProperty -Path $RegPath -Name '1' -Value '*' -Type String -Force
    Write-Log "Set ExtensionInstallBlocklist[1] = * (block all extensions)"

    # Verify
    $verify = Get-ItemProperty -Path $RegPath -Name '1' -ErrorAction SilentlyContinue
    if ($verify.'1' -eq '*') {
        Write-Log "Verification passed — all Chrome extensions are blocked"
    } else {
        throw "Verification failed — registry value not set correctly"
    }

    Write-Log "Set-ExtensionBlockAll-Chrome completed successfully"
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)" -Level 'ERROR'
    exit 1
}

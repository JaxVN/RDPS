# ============================================================
# Deploy Company Lock Screen + Desktop Wallpaper - Windows 11
# Deploy via: Action1 (runs as SYSTEM)
# Image path: C:\Users\Public\Pictures\KAG\
# Version: 2.0 | Updated: 2026-04-21
# ============================================================

#Requires -RunAsAdministrator

# ============================================================
# CONFIGURATION
# ============================================================
$Config = @{
    # Image URLs (thay đổi URL nếu cần)
    LockScreenUrl  = "https://raw.githubusercontent.com/kienagroup/P_Deloy/refs/heads/main/KA_desktop_2560x1440.jpg"
    WallpaperUrl   = "https://raw.githubusercontent.com/kienagroup/P_Deloy/refs/heads/main/KA_desktop_2560x1440.jpg"

    # Local paths
    ImageFolder    = "C:\Users\Public\Pictures\KAG"
    LockScreenFile = "KAG_LockScreen.jpg"
    WallpaperFile  = "KAG_Wallpaper.jpg"

    # Wallpaper Style: 10=Fill, 6=Fit, 2=Stretch, 0=Center, 22=Span
    WallpaperStyle = "10"
}

$LockScreenPath = Join-Path $Config.ImageFolder $Config.LockScreenFile
$WallpaperPath  = Join-Path $Config.ImageFolder $Config.WallpaperFile

# ============================================================
# FUNCTIONS
# ============================================================
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logLine = "[$timestamp] [$Level] $Message"
    Write-Host $logLine
}

function Download-Image {
    param(
        [string]$Url,
        [string]$Destination,
        [string]$Label
    )

    Write-Log "Downloading $Label from: $Url"

    try {
        # Force TLS 1.2
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop

        # Verify file exists and has content
        if (-not (Test-Path $Destination)) {
            throw "File not found after download: $Destination"
        }

        $fileSize = (Get-Item $Destination).Length
        if ($fileSize -lt 10KB) {
            Remove-Item $Destination -Force -ErrorAction SilentlyContinue
            throw "Downloaded file too small ($fileSize bytes) - likely corrupted or invalid"
        }

        Write-Log "$Label downloaded successfully ($([math]::Round($fileSize/1KB)) KB)"
        return $true
    }
    catch {
        Write-Log "Failed to download ${Label}: $_" "ERROR"
        return $false
    }
}

# ============================================================
# STEP 1: Prepare folder and download images
# ============================================================
Write-Log "=== KAG Lock Screen & Wallpaper Deployment ==="
Write-Log "Computer: $env:COMPUTERNAME | User context: $env:USERNAME"

# Create image folder
if (-not (Test-Path $Config.ImageFolder)) {
    New-Item -ItemType Directory -Path $Config.ImageFolder -Force | Out-Null
    Write-Log "Created folder: $($Config.ImageFolder)"
}

# Download Lock Screen image
$lockOk = Download-Image -Url $Config.LockScreenUrl -Destination $LockScreenPath -Label "Lock Screen"

# Download Wallpaper image (skip download if same URL - just copy)
if ($Config.LockScreenUrl -eq $Config.WallpaperUrl) {
    if ($lockOk) {
        Copy-Item -Path $LockScreenPath -Destination $WallpaperPath -Force
        Write-Log "Wallpaper = same image as Lock Screen, copied locally"
        $wallOk = $true
    } else {
        $wallOk = $false
    }
} else {
    $wallOk = Download-Image -Url $Config.WallpaperUrl -Destination $WallpaperPath -Label "Wallpaper"
}

if (-not $lockOk -and -not $wallOk) {
    Write-Log "Both downloads failed. Exiting." "ERROR"
    exit 1
}

# ============================================================
# STEP 2: Set Lock Screen via Local GPO Registry (Machine-wide)
# ============================================================
# GPO Path: Computer Configuration\Administrative Templates\
#           Control Panel\Personalization\
#           Force a specific default lock screen and logon image
# ============================================================
if ($lockOk) {
    Write-Log "--- Configuring Lock Screen (Machine Policy) ---"

    $regPersonalization = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"

    if (-not (Test-Path $regPersonalization)) {
        New-Item -Path $regPersonalization -Force | Out-Null
    }

    # LockScreenImage: đường dẫn ảnh lock screen
    Set-ItemProperty -Path $regPersonalization `
        -Name "LockScreenImage" -Value $LockScreenPath -Type String

    # LockScreenOverlaysDisabled: 1 = tắt fun facts/tips trên lock screen
    Set-ItemProperty -Path $regPersonalization `
        -Name "LockScreenOverlaysDisabled" -Value 1 -Type DWord

    # NoChangingLockScreen: 1 = ngăn user thay đổi lock screen
    Set-ItemProperty -Path $regPersonalization `
        -Name "NoChangingLockScreen" -Value 1 -Type DWord

    Write-Log "Lock Screen registry set: $LockScreenPath"
} else {
    Write-Log "Skipping Lock Screen configuration (download failed)" "WARN"
}

# ============================================================
# STEP 3: Set Desktop Wallpaper for ALL User Profiles
# ============================================================
# GPO Path: User Configuration\Administrative Templates\
#           Desktop\Desktop\Desktop Wallpaper
# Registry: HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System
#   Wallpaper (REG_SZ) = path to image
#   WallpaperStyle (REG_SZ) = style code
# 
# Vì Action1 chạy as SYSTEM, cần load từng user hive (ntuser.dat)
# ============================================================
if ($wallOk) {
    Write-Log "--- Configuring Desktop Wallpaper (All Users) ---"

    $wallpaperRegSubPath = "Software\Microsoft\Windows\CurrentVersion\Policies\System"

    # --- 3a: Apply to Default User Profile (new users) ---
    Write-Log "Applying wallpaper to Default User profile..."
    $defaultHive = "C:\Users\Default\NTUSER.DAT"
    $defaultLoaded = $false

    if (Test-Path $defaultHive) {
        try {
            & reg load "HKU\DefaultUser" $defaultHive 2>&1 | Out-Null
            $defaultLoaded = $true

            $defRegPath = "Registry::HKU\DefaultUser\$wallpaperRegSubPath"
            if (-not (Test-Path $defRegPath)) {
                New-Item -Path $defRegPath -Force | Out-Null
            }
            Set-ItemProperty -Path $defRegPath -Name "Wallpaper" -Value $WallpaperPath -Type String
            Set-ItemProperty -Path $defRegPath -Name "WallpaperStyle" -Value $Config.WallpaperStyle -Type String

            Write-Log "Default User profile configured"
        }
        catch {
            Write-Log "Failed to configure Default User: $_" "WARN"
        }
        finally {
            if ($defaultLoaded) {
                [gc]::Collect()
                Start-Sleep -Seconds 1
                & reg unload "HKU\DefaultUser" 2>&1 | Out-Null
            }
        }
    }

    # --- 3b: Apply to all existing user profiles ---
    Write-Log "Applying wallpaper to existing user profiles..."

    # Get user profiles from registry (excludes system accounts)
    $profileList = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" |
        Where-Object {
            $sid = $_.PSChildName
            # Only real user SIDs (S-1-5-21-...), skip system/service accounts
            $sid -match '^S-1-5-21-\d+-\d+-\d+-\d+$' -and
            $sid -notmatch '-500$' # Optionally skip built-in Administrator
        }

    foreach ($profile in $profileList) {
        $sid = $profile.PSChildName
        $profilePath = (Get-ItemProperty $profile.PSPath).ProfileImagePath

        if (-not $profilePath -or -not (Test-Path $profilePath)) {
            Write-Log "Profile path not found for SID $sid, skipping" "WARN"
            continue
        }

        $userName = Split-Path $profilePath -Leaf
        $hivePath = Join-Path $profilePath "NTUSER.DAT"

        if (-not (Test-Path $hivePath)) {
            Write-Log "NTUSER.DAT not found for $userName, skipping" "WARN"
            continue
        }

        # Check if hive is already loaded (user logged in)
        $hiveLoaded = $false
        $regRoot = $null

        if (Test-Path "Registry::HKU\$sid") {
            # User is logged in, hive already loaded
            $regRoot = "Registry::HKU\$sid"
            Write-Log "User $userName (logged in) - applying directly"
        } else {
            # User not logged in, load hive
            $tempKey = "HKU\TEMP_$($userName.Replace(' ','_'))"
            try {
                & reg load $tempKey $hivePath 2>&1 | Out-Null
                $hiveLoaded = $true
                $regRoot = "Registry::$tempKey"
                Write-Log "User $userName (offline) - hive loaded"
            }
            catch {
                Write-Log "Failed to load hive for $userName : $_" "WARN"
                continue
            }
        }

        # Apply wallpaper policy
        try {
            $userPolicyPath = "$regRoot\$wallpaperRegSubPath"

            if (-not (Test-Path $userPolicyPath)) {
                New-Item -Path $userPolicyPath -Force | Out-Null
            }

            Set-ItemProperty -Path $userPolicyPath -Name "Wallpaper" -Value $WallpaperPath -Type String
            Set-ItemProperty -Path $userPolicyPath -Name "WallpaperStyle" -Value $Config.WallpaperStyle -Type String

            # Also prevent user from changing wallpaper (optional - comment out if not needed)
            # Set-ItemProperty -Path "$regRoot\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" `
            #     -Name "NoChangingWallPaper" -Value 1 -Type DWord

            Write-Log "Wallpaper configured for $userName"
        }
        catch {
            Write-Log "Failed to set wallpaper for $userName : $_" "WARN"
        }
        finally {
            # Unload hive if we loaded it
            if ($hiveLoaded) {
                [gc]::Collect()
                Start-Sleep -Milliseconds 500
                & reg unload $tempKey 2>&1 | Out-Null
            }
        }
    }

    Write-Log "Desktop Wallpaper deployment complete"
} else {
    Write-Log "Skipping Wallpaper configuration (download failed)" "WARN"
}

# ============================================================
# STEP 4: Force GPO refresh
# ============================================================
Write-Log "--- Refreshing Group Policy ---"
try {
    gpupdate /force 2>&1 | Out-Null
    Write-Log "Group Policy refreshed"
}
catch {
    Write-Log "gpupdate failed (non-critical): $_" "WARN"
}

# ============================================================
# STEP 5: Summary
# ============================================================
Write-Log "=== Deployment Summary ==="
Write-Log "Lock Screen : $(if ($lockOk) { 'OK - ' + $LockScreenPath } else { 'FAILED' })"
Write-Log "Wallpaper   : $(if ($wallOk) { 'OK - ' + $WallpaperPath } else { 'FAILED' })"
Write-Log "Computer    : $env:COMPUTERNAME"
Write-Log "Note: Wallpaper thay đổi sau khi user log off / log on lại"
Write-Log "=== Done ==="

exit 0

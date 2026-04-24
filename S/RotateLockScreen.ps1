# KAG Lock Screen Rotation Script
# Runs as SYSTEM via Scheduled Task
# Picks a random image from LS folder and replaces default lock screen images

$lsFolder = "C:\Users\Public\Pictures\S\LS"
$screenDir = "C:\Windows\Web\Screen"
$systemDataDir = "C:\ProgramData\Microsoft\Windows\SystemData"

# Get available images
$images = @(Get-ChildItem -Path $lsFolder -File -Include *.jpg,*.jpeg,*.png,*.bmp -ErrorAction SilentlyContinue)
if ($images.Count -eq 0) { exit 0 }

# Pick a random image
$selected = $images | Get-Random
$logTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Output "[$logTime] Selected: $($selected.Name)"

# Replace C:\Windows\Web\Screen\img*
$imgFiles = Get-ChildItem -Path $screenDir -Filter "img*" -File -ErrorAction SilentlyContinue
foreach ($img in $imgFiles) {
    Copy-Item -Path $selected.FullName -Destination $img.FullName -Force -ErrorAction SilentlyContinue
}

# Replace SystemData cache
if (Test-Path $systemDataDir) {
    $lockDirs = Get-ChildItem -Path $systemDataDir -Recurse -Directory -Filter "LockScreen_*" -ErrorAction SilentlyContinue
    foreach ($lockDir in $lockDirs) {
        $existingImages = Get-ChildItem -Path $lockDir.FullName -File -ErrorAction SilentlyContinue
        foreach ($existingImg in $existingImages) {
            Copy-Item -Path $selected.FullName -Destination $existingImg.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}

# Update GPO registry pointer
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
if (Test-Path $regPath) {
    Set-ItemProperty -Path $regPath -Name "LockScreenImage" -Value $selected.FullName -Type String -ErrorAction SilentlyContinue
}

Write-Output "[$logTime] Lock screen rotated to: $($selected.Name)"

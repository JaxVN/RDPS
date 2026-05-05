# =============================================
# s2.ps1 - CHỈ THIẾT LẬP BACKGROUND & LOCK SCREEN
# =============================================

$BasePath = "C:\Users\Public\Public Pictures\S"
$DS_Path  = Join-Path $BasePath "DS"
$LS_Path  = Join-Path $BasePath "LS"

Write-Host "🔧 Đang thiết lập Background và Lock Screen..." -ForegroundColor Cyan

if (-not (Test-Path $DS_Path) -or -not (Test-Path $LS_Path)) {
    Write-Host "❌ Không tìm thấy thư mục DS hoặc LS tại: $BasePath" -ForegroundColor Red
    exit 1
}

# ==================== DESKTOP BACKGROUND ====================
Write-Host "   • Thiết lập Desktop Background (DS)..." -ForegroundColor Yellow

$RegDesktop = "HKCU:\Control Panel\Personalization\Desktop Slideshow"
if (-not (Test-Path $RegDesktop)) { New-Item -Path $RegDesktop -Force | Out-Null }

Set-ItemProperty -Path $RegDesktop -Name "SlideshowDirectoryPath" -Value $DS_Path -Force
Set-ItemProperty -Path $RegDesktop -Name "Interval" -Value 1800000 -Force        # 30 phút
Set-ItemProperty -Path $RegDesktop -Name "Shuffle" -Value 0 -Force

# ==================== LOCK SCREEN ====================
Write-Host "   • Thiết lập Lock Screen (LS)..." -ForegroundColor Yellow

$RegLock = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"
if (-not (Test-Path $RegLock)) { New-Item -Path $RegLock -Force | Out-Null }

Set-ItemProperty -Path $RegLock -Name "SlideshowEnabled" -Value 1 -Force
Set-ItemProperty -Path $RegLock -Name "SlideshowDirectoryPath" -Value $LS_Path -Force
Set-ItemProperty -Path $RegLock -Name "SlideShowDuration" -Value 1800000 -Force

# Tắt Windows Spotlight
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

Write-Host "✅ Đã thiết lập hoàn tất Background (DS) và Lock Screen (LS)!" -ForegroundColor Green
Write-Host "   → Desktop : $DS_Path" -ForegroundColor Green
Write-Host "   → LockScreen: $LS_Path" -ForegroundColor Green

# Áp dụng ngay
Start-Process -FilePath "RUNDLL32.EXE" -ArgumentList "USER32.DLL,UpdatePerUserSystemParameters 1,True" -NoNewWindow -Wait -ErrorAction SilentlyContinue

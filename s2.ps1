# =============================================
# THIẾT LẬP BACKGROUND & LOCK SCREEN (theo hướng dẫn KAG-ITUG-031)
# =============================================

$BasePath = "C:\Users\Public\Public Pictures\S"
$DS_Path  = Join-Path $BasePath "DS"   # Background Slideshow
$LS_Path  = Join-Path $BasePath "LS"   # Lock Screen Slideshow

Write-Host "🔧 Đang thiết lập Background và Lock Screen..." -ForegroundColor Cyan

# Kiểm tra thư mục tồn tại
if (-not (Test-Path $DS_Path) -or -not (Test-Path $LS_Path)) {
    Write-Host "❌ Không tìm thấy thư mục DS hoặc LS!" -ForegroundColor Red
    Write-Host "Vui lòng kiểm tra đường dẫn: $BasePath" -ForegroundColor Red
    exit 1
}

# ------------------- DESKTOP BACKGROUND (Slideshow) -------------------
Write-Host "   • Thiết lập Desktop Background (Slideshow - DS folder)..." -ForegroundColor Yellow

$RegPathDesktop = "HKCU:\Control Panel\Personalization\Desktop Slideshow"

# Tạo key nếu chưa có
if (-not (Test-Path $RegPathDesktop)) {
    New-Item -Path $RegPathDesktop -Force | Out-Null
}

Set-ItemProperty -Path $RegPathDesktop -Name "SlideshowDirectoryPath" -Value $DS_Path -Force
Set-ItemProperty -Path $RegPathDesktop -Name "Interval" -Value 1800000 -Force          # 30 phút
Set-ItemProperty -Path $RegPathDesktop -Name "Shuffle" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name "backgroundType" -Value 2 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" -Name "SlideshowEnabled" -Value 1 -Force -ErrorAction SilentlyContinue

# ------------------- LOCK SCREEN (Slideshow) -------------------
Write-Host "   • Thiết lập Lock Screen (Slideshow - LS folder)..." -ForegroundColor Yellow

$RegPathLock = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Lock Screen"

if (-not (Test-Path $RegPathLock)) {
    New-Item -Path $RegPathLock -Force | Out-Null
}

Set-ItemProperty -Path $RegPathLock -Name "SlideshowEnabled" -Value 1 -Force
Set-ItemProperty -Path $RegPathLock -Name "SlideshowDirectoryPath" -Value $LS_Path -Force
Set-ItemProperty -Path $RegPathLock -Name "SlideShowDuration" -Value 1800000 -Force     # 30 phút

# Tắt một số tính năng Spotlight
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Force

# Áp dụng thay đổi
Start-Process -FilePath "RUNDLL32.EXE" -ArgumentList "USER32.DLL,UpdatePerUserSystemParameters 1,True" -NoNewWindow -Wait -ErrorAction SilentlyContinue

Write-Host "✅ Đã thiết lập hoàn tất Background (DS) và Lock Screen (LS)!" -ForegroundColor Green
Write-Host "   Desktop Background → $DS_Path" -ForegroundColor Green
Write-Host "   Lock Screen        → $LS_Path" -ForegroundColor Green

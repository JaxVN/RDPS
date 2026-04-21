# ============================================
# Deploy Company Lock Screen - Windows 11
# Image path: C:\Users\Public\Pictures
# ============================================

# Định nghĩa URL và nơi lưu
$imageUrl = "https://raw.githubusercontent.com/kienagroup/P_Deloy/refs/heads/main/KA_desktop_2560x1440.jpg"
$destinationPath = "C:\Users\Public\Pictures\KA_desktop_2560x1440.jpg"

# Tạo thư mục nếu chưa tồn tại
$destinationDir = Split-Path $destinationPath -Parent
if (-not (Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force
}

# Tải ảnh
try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $destinationPath -UseBasicParsing -ErrorAction Stop
    Write-Host "Tải ảnh Lock Screen thành công."
} catch {
    Write-Host "Lỗi tải ảnh: $_"
    exit 1
}

# ============================================
# Set Lock Screen qua Local Group Policy (HKLM)
# ============================================

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force
}

# Chỉ định ảnh Lock Screen
Set-ItemProperty `
    -Path $regPath `
    -Name "LockScreenImage" `
    -Value $destinationPath `
    -Type String

# Bắt buộc dùng ảnh này
Set-ItemProperty `
    -Path $regPath `
    -Name "LockScreenImageStatus" `
    -Value 1 `
    -Type DWord

# Hiển thị ảnh lockscreen ở màn hình sign-in
Set-ItemProperty `
    -Path $regPath `
    -Name "NoLockScreen" `
    -Value 0 `
    -Type DWord

Write-Host "Hoàn tất thiết lập Lock Screen cho toàn bộ hệ thống."

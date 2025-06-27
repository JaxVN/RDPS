# Định nghĩa URL của ảnh nền và đường dẫn lưu trữ
$imageUrl = "https://raw.githubusercontent.com/kienagroup/P_Deloy/refs/heads/main/KA_desktop_2560x1440.jpg"
$destinationPath = "C:\Users\Public\Pictures\KA_desktop_2560x1440.jpg"

# Tạo thư mục đích nếu chưa tồn tại
$destinationDir = Split-Path -Path $destinationPath -Parent
if (-not (Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force
}

# Tải ảnh từ URL
try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $destinationPath -ErrorAction Stop
    Write-Host "Đã tải ảnh nền thành công từ $imageUrl."
} catch {
    Write-Host "Lỗi khi tải ảnh từ $imageUrl : $_"
    exit 1
}

# Kiểm tra xem file ảnh đã được tải thành công
if (Test-Path $destinationPath) {
    # Đặt ảnh nền thông qua Registry
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $destinationPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value 2  # 2 = Fit
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value 0

    # Cập nhật ảnh nền ngay lập tức
    rundll32.exe user32.dll, UpdatePerUserSystemParameters

    Write-Host "Đã thiết lập ảnh nền thành công."
} else {
    Write-Host "Không tìm thấy file ảnh tại: $destinationPath"
    exit 1
}

# Khóa cài đặt ảnh nền
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
$regKey = "ActiveDesktop"

if (-not (Test-Path "$regPath\$regKey")) {
    New-Item -Path $regPath -Name $regKey -Force
}

Set-ItemProperty -Path "$regPath\$regKey" -Name "NoChangingWallPaper" -Value 1

Write-Host "Đã khóa cài đặt thay đổi ảnh nền."

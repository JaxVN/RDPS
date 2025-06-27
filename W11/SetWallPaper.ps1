# Định nghĩa URL và nơi lưu
$imageUrl = "https://raw.githubusercontent.com/kienagroup/P_Deloy/refs/heads/main/KA_desktop_2560x1440.jpg"
$destinationPath = "C:\Users\Public\Pictures\KA_desktop_2560x1440.jpg"

# Tạo thư mục
$destinationDir = Split-Path $destinationPath -Parent
if (-not (Test-Path $destinationDir)) {
    New-Item -ItemType Directory -Path $destinationDir -Force
}

# Tải ảnh
try {
    Invoke-WebRequest -Uri $imageUrl -OutFile $destinationPath -UseBasicParsing -ErrorAction Stop
    Write-Host "Tải ảnh thành công."
} catch {
    Write-Host "Lỗi tải ảnh: $_"
    exit 1
}

# Set hình nền qua tất cả user SID
$hku = Get-ChildItem Registry::HKEY_USERS | Where-Object {
    $_.Name -notmatch "_Classes$"
}

foreach ($sid in $hku) {
    try {
        # HKCU equivalent
        $regPath = "Registry::" + $sid.Name + "\Control Panel\Desktop"

        Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $destinationPath -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "WallpaperStyle" -Value 2 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "TileWallpaper" -Value 0 -ErrorAction SilentlyContinue

        # Khóa chỉnh sửa
        $policyPath = "Registry::" + $sid.Name + "\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
        if (-not (Test-Path $policyPath)) {
            New-Item -Path $policyPath -Force
        }
        Set-ItemProperty -Path $policyPath -Name "NoChangingWallPaper" -Value 1

        Write-Host "Đã set hình nền và khoá cho user SID $($sid.PSChildName)"
    } catch {
        Write-Host "Lỗi user $($sid.PSChildName): $_"
    }
}

# Xoá theme cache
$themeCache = "$env:APPDATA\Microsoft\Windows\Themes"
if (Test-Path $themeCache) {
    Remove-Item "$themeCache\*" -Force -ErrorAction SilentlyContinue
    Write-Host "Đã xoá cache theme."
}

Write-Host "Hoàn tất thiết lập hình nền cho toàn bộ user."

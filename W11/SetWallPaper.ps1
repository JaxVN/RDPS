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
    # Xóa cache ảnh nền để tránh lỗi màn hình đen
    $themeCache = "$env:APPDATA\Microsoft\Windows\Themes"
    if (Test-Path $themeCache) {
        Remove-Item -Path "$themeCache\*" -Force -ErrorAction SilentlyContinue
        Write-Host "Đã xóa cache ảnh nền."
    }

    # Đặt ảnh nền cho tất cả người dùng qua HKLM
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force
    }
    Set-ItemProperty -Path $regPath -Name "DesktopImagePath" -Value $destinationPath
    Set-ItemProperty -Path $regPath -Name "DesktopImageStatus" -Value 1
    Set-ItemProperty -Path $regPath -Name "DesktopImageUrl" -Value $imageUrl

    # Đặt kiểu hiển thị ảnh nền (Fit)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "WallpaperStyle" -Value 2
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "TileWallpaper" -Value 0

    # Đặt ảnh nền cho người dùng hiện tại qua HKCU
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $destinationPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "WallpaperStyle" -Value 2
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "TileWallpaper" -Value 0

    # Áp dụng ảnh nền ngay lập tức
    try {
        $code = @"
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
"@
        $type = Add-Type -MemberDefinition $code -Name Win32SystemParametersInfo -Namespace Win32Functions -PassThru
        $type::SystemParametersInfo(20, 0, $destinationPath, 3) | Out-Null
        Write-Host "Đã áp dụng ảnh nền thành công."
    } catch {
        Write-Host "Lỗi khi áp dụng ảnh nền: $_"
    }

    # Khóa thay đổi ảnh nền cho tất cả người dùng qua HKLM
    $policyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    if (-not (Test-Path $policyPath)) {
        New-Item -Path $policyPath -Force
    }
    Set-ItemProperty -Path $policyPath -Name "Wallpaper" -Value $destinationPath
    Set-ItemProperty -Path $policyPath -Name "WallpaperStyle" -Value 2

    $activeDesktopPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
    if (-not (Test-Path $activeDesktopPath)) {
        New-Item -Path $activeDesktopPath -Force
    }
    Set-ItemProperty -Path $activeDesktopPath -Name "NoChangingWallPaper" -Value 1

    # Khóa thay đổi ảnh nền cho người dùng hiện tại qua HKCU
    $userPolicyPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
    if (-not (Test-Path $userPolicyPath)) {
        New-Item -Path $userPolicyPath -Force
    }
    Set-ItemProperty -Path $userPolicyPath -Name "NoChangingWallPaper" -Value 1
} else {
    Write-Host "Không tìm thấy file ảnh tại: $destinationPath"
    exit 1
}

Write-Host "Đã thiết lập và khóa ảnh nền cho tất cả người dùng."

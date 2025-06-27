# LockWallPaper.ps1
$destinationPath = "C:\Users\Public\Pictures\KA_desktop_2560x1440.jpg"

$hku = Get-ChildItem Registry::HKEY_USERS | Where-Object {
    $_.Name -notmatch "_Classes$"
}

foreach ($sid in $hku) {
    try {
        $regPath = "Registry::" + $sid.Name + "\Control Panel\Desktop"
        Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $destinationPath -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "WallpaperStyle" -Value 2 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $regPath -Name "TileWallpaper" -Value 0 -ErrorAction SilentlyContinue

        # khóa chỉnh sửa
        $policyPath = "Registry::" + $sid.Name + "\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
        if (-not (Test-Path $policyPath)) {
            New-Item -Path $policyPath -Force
        }
        Set-ItemProperty -Path $policyPath -Name "NoChangingWallPaper" -Value 1

        Write-Host "Đã khoá chỉnh sửa cho user SID $($sid.PSChildName)"
    } catch {
        Write-Host "Lỗi user $($sid.PSChildName): $_"
    }
}

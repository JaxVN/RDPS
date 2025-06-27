# UnlockWallpaper.ps1

# Duyệt toàn bộ user SID (bỏ qua _Classes)
$hku = Get-ChildItem Registry::HKEY_USERS | Where-Object {
    $_.Name -notmatch "_Classes$"
}

foreach ($sid in $hku) {
    try {
        # mở khóa trong policies
        $policyPath = "Registry::" + $sid.Name + "\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop"
        if (Test-Path $policyPath) {
            Remove-ItemProperty -Path $policyPath -Name "NoChangingWallPaper" -ErrorAction SilentlyContinue
            Write-Host "Đã mở khóa chỉnh sửa hình nền cho user SID $($sid.PSChildName)"
        }
        else {
            Write-Host "Không tìm thấy policy ActiveDesktop cho user SID $($sid.PSChildName)"
        }
    } catch {
        Write-Host "Lỗi mở khóa user $($sid.PSChildName): $_"
    }
}

# master.ps1
try {
    . "$PSScriptRoot\DownloadWallpaper.ps1"
    . "$PSScriptRoot\LockWallPaper.ps1"
    Write-Host "Đã chạy master.ps1 thành công."
} catch {
    Write-Host "Có lỗi khi chạy master.ps1: $_"
}

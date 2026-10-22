# =============================================
# PoC - Cài 3 bộ phần mềm từ 1 file nén
# =============================================

# URL SharePoint của file nén mới (bạn thay bằng link thật + &download=1)
$url = "https://kaglav.sharepoint.com/:u:/s/IT/IQDy8E0cq4dIQLFUkOsNa_pbAZYyKa57WuYKGk3q5ubnqhs&download=1"

$zipPath     = "C:\FAST\PoC_01.Zip"
$extractPath = "C:\FAST"
$publicDesktop = "C:\Users\Public\Desktop"

# Tạo thư mục C:\FAST nếu chưa có
if (-not (Test-Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force | Out-Null
}

try {
    Write-Host "Đang tải file nén từ SharePoint..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing -ErrorAction Stop

    Write-Host "Đang giải nén..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    # Danh sách 3 shortcut cần copy
    $shortcuts = @("PoC_01.lnk", "PoC_02.lnk", "PoC_03.lnk")

    foreach ($shortcut in $shortcuts) {
        $source = Join-Path -Path $extractPath -ChildPath $shortcut

        if (Test-Path $source) {
            Copy-Item -Path $source -Destination $publicDesktop -Force
            Write-Host "Đã copy: $shortcut → Public Desktop" -ForegroundColor Green
        } else {
            Write-Host "Không tìm thấy shortcut: $shortcut" -ForegroundColor Yellow
        }
    }

    # Xóa file ZIP sau khi giải nén
    Remove-Item -Path $zipPath -Force -ErrorAction SilentlyContinue

    Write-Host "`nHoàn tất cài đặt 3 bộ PoC!" -ForegroundColor Green
}
catch {
    Write-Host "Lỗi: $_" -ForegroundColor Red
    exit 1
}

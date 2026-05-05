# =============================================
# ACTION1 - Copy thư mục S từ GitHub về máy nhân viên
# =============================================

$RepoUrl = "https://github.com/JaxVN/RDPS/archive/refs/heads/main.zip"
$TempZip = "$env:TEMP\RDPS-main.zip"
$ExtractPath = "$env:TEMP\RDPS-main"
$TargetFolder = "C:\RDPS_S"          # Thư mục đích trên máy nhân viên

Write-Host "🔄 Đang tải thư mục S từ GitHub..." -ForegroundColor Cyan

# Tải repo về dạng ZIP
try {
    Invoke-WebRequest -Uri $RepoUrl -OutFile $TempZip -UseBasicParsing
} catch {
    Write-Host "❌ Lỗi khi tải file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Giải nén
Write-Host "📦 Đang giải nén..." -ForegroundColor Cyan
Expand-Archive -Path $TempZip -DestinationPath $ExtractPath -Force

# Copy thư mục S sang vị trí đích
$SourceS = Join-Path $ExtractPath "RDPS-main\S"

if (Test-Path $SourceS) {
    if (Test-Path $TargetFolder) {
        Remove-Item -Path $TargetFolder -Recurse -Force
    }
    Copy-Item -Path $SourceS -Destination $TargetFolder -Recurse -Force
    Write-Host "✅ Đã copy thành công thư mục S vào: $TargetFolder" -ForegroundColor Green
} else {
    Write-Host "❌ Không tìm thấy thư mục S trong repository!" -ForegroundColor Red
}

# Dọn dẹp file tạm
Remove-Item -Path $TempZip -Force -ErrorAction SilentlyContinue
Remove-Item -Path $ExtractPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Hoàn tất!" -ForegroundColor Green
pause

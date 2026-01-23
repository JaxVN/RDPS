# Script: Tạo các thư mục theo cấu trúc [Mã công ty]_FA12 trong C:\FAST
# Đường dẫn gốc
$basePath = "C:\FAST"

# 1. Kiểm tra và thử tạo thư mục gốc
try {
    if (-not (Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath -Force -ErrorAction Stop | Out-Null
        Write-Host "Đã tạo thư mục gốc: $basePath" -ForegroundColor Green
    }
} catch {
    Write-Host "Không có quyền tạo C:\FAST. Chuyển sang thư mục người dùng." -ForegroundColor Yellow
    $basePath = Join-Path $env:LOCALAPPDATA "FAST"
    if (-not (Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath -Force | Out-Null
    }
}

# 2. Danh sách mã công ty
$companyCodes = @(
    "ATC", "ATL", "DHP", "DNA", "DTC", "DTE", "DTL", "HAN", "HTH", "KAB", "KAH", "KAK", "KAL", "KAS", "KAY", "KIA",
    "KSL", "KTC", "LAH", "LBT", "LPK", "MCR", "MTX", "NAN", "NTO", "NTP", "PHK", "PTL", "RC9", "SAP", "SIC", "SIT",
    "SNP", "SPM", "STL", "TGM", "TTP", "UMT", "VAN", "VCN", "VPH", "VTL", "VVP", "XDA", "XPH", "ALP", "BTT", "HAS"
)

# 3. Tiến hành tạo thư mục con với hậu tố _FA12
$createdCount = 0
$skippedCount = 0

foreach ($code in $companyCodes) {
    # Cấu trúc tên thư mục mới: Mã_FA12
    $folderName = $code + "_FA12"
    $folderPath = Join-Path $basePath $folderName
    
    if (-not (Test-Path $folderPath)) {
        try {
            New-Item -ItemType Directory -Path $folderPath -Force -ErrorAction Stop | Out-Null
            Write-Host "成功 [OK]: $folderName" -ForegroundColor Green
            $createdCount++
        } catch {
            Write-Warning "Lỗi khi tạo $folderName : $($_.Exception.Message)"
        }
    } else {
        Write-Host "Bỏ qua [Đã tồn tại]: $folderName" -ForegroundColor Gray
        $skippedCount++
    }
}

# 4. Tổng kết
Write-Host "`n--- TỔNG KẾT ---" -ForegroundColor Magenta
Write-Host "↳ Vị trí lưu: $basePath"
Write-Host "↳ Tổng số mã: $($companyCodes.Count)"
Write-Host "↳ Đã tạo mới: $createdCount"
Write-Host "↳ Đã tồn tại: $skippedCount"
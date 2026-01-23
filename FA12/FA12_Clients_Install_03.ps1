# Script: Copy dữ liệu từ FA12 mẫu vào các thư mục công ty tương ứng
# -------------------------------------------------------------------------

# 1. Cấu hình đường dẫn
$basePath = "C:\FAST"
$sourcePath = "C:\FAST\FA12" # Thư mục chứa dữ liệu gốc

# Kiểm tra nếu thư mục gốc FA12 không tồn tại thì dừng lại
if (-not (Test-Path $sourcePath)) {
    Write-Host "LỖI: Không tìm thấy thư mục nguồn tại $sourcePath" -ForegroundColor Red
    return
}

# 2. Danh sách mã công ty (giống danh sách trên)
$companyCodes = @(
    "ATC", "ATL", "DHP", "DNA", "DTC", "DTE", "DTL", "HAN", "HTH", "KAB", "KAH", "KAK", "KAL", "KAS", "KAY", "KIA",
    "KSL", "KTC", "LAH", "LBT", "LPK", "MCR", "MTX", "NAN", "NTO", "NTP", "PHK", "PTL", "RC9", "SAP", "SIC", "SIT",
    "SNP", "SPM", "STL", "TGM", "TTP", "UMT", "VAN", "VCN", "VPH", "VTL", "VVP", "XDA", "XPH", "ALP", "BTT", "HAS"
)

# 3. Tiến hành Copy dữ liệu
$successCount = 0

foreach ($code in $companyCodes) {
    $folderName = $code + "_FA12"
    $destinationPath = Join-Path $basePath $folderName
    
    # Kiểm tra nếu thư mục đích tồn tại thì mới copy
    if (Test-Path $destinationPath) {
        try {
            # Copy toàn bộ nội dung bên trong FA12 vào thư mục đích
            Copy-Item -Path "$sourcePath\*" -Destination $destinationPath -Recurse -Force -ErrorAction Stop
            Write-Host "✔ Đã đổ dữ liệu vào: $folderName" -ForegroundColor Green
            $successCount++
        } catch {
            Write-Warning "✘ Lỗi khi copy vào $folderName : $($_.Exception.Message)"
        }
    } else {
        Write-Host "⚠ Bỏ qua: Thư mục $folderName không tồn tại." -ForegroundColor Yellow
    }
}

# 4. Tổng kết
Write-Host "`n" + ("="*40) -ForegroundColor Magenta
Write-Host "HOÀN TẤT: Đã copy xong dữ liệu cho $successCount thư mục." -ForegroundColor Magenta
Write-Host ("="*40) -ForegroundColor Magenta
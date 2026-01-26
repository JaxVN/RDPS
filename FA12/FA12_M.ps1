# =========================================================================
# Script: Cài đặt FA12 cho nhiều công ty - Phiên bản hợp nhất
# Mô tả: Download, giải nén và phân phối FA12 cho tất cả các công ty
# =========================================================================

# Cấu hình
$url = "https://kaglav.sharepoint.com/:u:/s/IT/IQD8s_DKsSM3SIF-T-gAI5GUAeXEV7KDLlfqEC23Zgs6RdU?e=z28XBk"
$basePath = "C:\FAST"
$zipPath = Join-Path $basePath "KIA_FA12.Zip"
$sourcePath = Join-Path $basePath "FA12"
$shortcutName = "KIA_FA12.lnk"
$publicDesktop = "C:\Users\Public\Desktop"

# Danh sách mã công ty
$companyCodes = @(
    "ATC", "ATL", "DHP", "DNA", "DTC", "DTE", "DTL", "HAN", "HTH", "KAB", "KAH", "KAK", "KAL", "KAS", "KAY", "KIA",
    "KSL", "KTC", "LAH", "LBT", "LPK", "MCR", "MTX", "NAN", "NTO", "NTP", "PHK", "PTL", "RC9", "SAP", "SIC", "SIT",
    "SNP", "SPM", "STL", "TGM", "TTP", "UMT", "VAN", "VCN", "VPH", "VTL", "VVP", "XDA", "XPH", "ALP", "BTT", "HAS"
)

# Thống kê
$stats = @{
    FoldersCreated = 0
    FoldersSkipped = 0
    DataCopied = 0
    DataFailed = 0
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   CÀI ĐẶT FA12 CHO NHIỀU CÔNG TY" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# =========================================================================
# BƯỚC 1: TẠO THƯ MỤC GỐC
# =========================================================================
Write-Host "[1/5] Kiểm tra và tạo thư mục gốc..." -ForegroundColor Yellow

try {
    if (-not (Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath -Force -ErrorAction Stop | Out-Null
        Write-Host "  ✔ Đã tạo thư mục: $basePath" -ForegroundColor Green
    } else {
        Write-Host "  ✔ Thư mục đã tồn tại: $basePath" -ForegroundColor Green
    }
} catch {
    Write-Host "  ✘ Không có quyền tạo $basePath. Chuyển sang thư mục người dùng." -ForegroundColor Red
    $basePath = Join-Path $env:LOCALAPPDATA "FAST"
    $zipPath = Join-Path $basePath "KIA_FA12.Zip"
    $sourcePath = Join-Path $basePath "FA12"
    
    if (-not (Test-Path $basePath)) {
        New-Item -ItemType Directory -Path $basePath -Force | Out-Null
        Write-Host "  ✔ Đã tạo thư mục: $basePath" -ForegroundColor Green
    }
}

# =========================================================================
# BƯỚC 2: DOWNLOAD FILE NÉN (1 LẦN DUY NHẤT)
# =========================================================================
Write-Host "`n[2/5] Download file nén từ SharePoint..." -ForegroundColor Yellow

if (Test-Path $zipPath) {
    Write-Host "  ⚠ File zip đã tồn tại. Bỏ qua download." -ForegroundColor Gray
    Write-Host "  ↳ Nếu muốn tải lại, xóa file: $zipPath" -ForegroundColor Gray
} else {
    try {
        Write-Host "  ↳ Đang tải từ SharePoint..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $zipPath -ErrorAction Stop
        Write-Host "  ✔ Download thành công!" -ForegroundColor Green
    } catch {
        Write-Host "  ✘ Lỗi download: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
}

# =========================================================================
# BƯỚC 3: GIẢI NÉN FILE
# =========================================================================
Write-Host "`n[3/5] Giải nén file..." -ForegroundColor Yellow

if (Test-Path $sourcePath) {
    Write-Host "  ⚠ Thư mục FA12 đã tồn tại. Bỏ qua giải nén." -ForegroundColor Gray
} else {
    try {
        Expand-Archive -Path $zipPath -DestinationPath $basePath -Force -ErrorAction Stop
        Write-Host "  ✔ Giải nén thành công vào: $basePath" -ForegroundColor Green
    } catch {
        Write-Host "  ✘ Lỗi giải nén: $($_.Exception.Message)" -ForegroundColor Red
        return
    }
}

# Kiểm tra thư mục FA12 sau khi giải nén
if (-not (Test-Path $sourcePath)) {
    Write-Host "  ✘ Không tìm thấy thư mục FA12 sau khi giải nén!" -ForegroundColor Red
    return
}

# Lưu ý: Không copy shortcut gốc vì mỗi công ty cần shortcut riêng
Write-Host "  ✔ Sẽ tạo shortcut riêng cho từng công ty ở bước 5" -ForegroundColor Green

# Xóa file zip để tiết kiệm dung lượng
if (Test-Path $zipPath) {
    Remove-Item -Path $zipPath -Force
    Write-Host "  ✔ Đã xóa file zip" -ForegroundColor Green
}

# =========================================================================
# BƯỚC 4: TẠO CÁC THƯ MỤC CÔNG TY
# =========================================================================
Write-Host "`n[4/5] Tạo các thư mục công ty..." -ForegroundColor Yellow

foreach ($code in $companyCodes) {
    $folderName = $code + "_FA12"
    $folderPath = Join-Path $basePath $folderName
    
    if (-not (Test-Path $folderPath)) {
        try {
            New-Item -ItemType Directory -Path $folderPath -Force -ErrorAction Stop | Out-Null
            Write-Host "  ✔ Tạo: $folderName" -ForegroundColor Green
            $stats.FoldersCreated++
        } catch {
            Write-Host "  ✘ Lỗi tạo $folderName : $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⊙ Đã có: $folderName" -ForegroundColor Gray
        $stats.FoldersSkipped++
    }
}

# =========================================================================
# BƯỚC 5: COPY DỮ LIỆU VÀO CÁC THƯ MỤC VÀ TẠO SHORTCUT
# =========================================================================
Write-Host "`n[5/5] Copy dữ liệu và tạo shortcut cho từng công ty..." -ForegroundColor Yellow

# Tạo COM Object để tạo shortcut
$WshShell = New-Object -ComObject WScript.Shell

foreach ($code in $companyCodes) {
    $folderName = $code + "_FA12"
    $destinationPath = Join-Path $basePath $folderName
    
    if (Test-Path $destinationPath) {
        # Copy dữ liệu
        try {
            Copy-Item -Path "$sourcePath\*" -Destination $destinationPath -Recurse -Force -ErrorAction Stop
            Write-Host "  ✔ Copy dữ liệu: $folderName" -ForegroundColor Green
            $stats.DataCopied++
            
            # Tạo shortcut riêng cho công ty này
            $shortcutPath = Join-Path $publicDesktop "$folderName.lnk"
            $targetExe = Join-Path $destinationPath "SmStartup.exe"
            
            if (Test-Path $targetExe) {
                $Shortcut = $WshShell.CreateShortcut($shortcutPath)
                $Shortcut.TargetPath = $targetExe
                $Shortcut.WorkingDirectory = $destinationPath
                $Shortcut.WindowStyle = 1  # Normal window
                $Shortcut.Description = "FA12 - $code"
                
                # Tìm icon (nếu có)
                $iconPath = Join-Path $destinationPath "SmStartup.exe"
                if (Test-Path $iconPath) {
                    $Shortcut.IconLocation = $iconPath
                }
                
                $Shortcut.Save()
                Write-Host "    ↳ Tạo shortcut: $folderName.lnk" -ForegroundColor Cyan
            } else {
                Write-Host "    ⚠ Không tìm thấy SmStartup.exe trong $folderName" -ForegroundColor Yellow
            }
            
        } catch {
            Write-Host "  ✘ Lỗi xử lý $folderName : $($_.Exception.Message)" -ForegroundColor Red
            $stats.DataFailed++
        }
    } else {
        Write-Host "  ⚠ Bỏ qua: $folderName không tồn tại" -ForegroundColor Yellow
    }
}

# Giải phóng COM Object
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($WshShell) | Out-Null

# =========================================================================
# TỔNG KẾT
# =========================================================================
Write-Host "`n========================================" -ForegroundColor Magenta
Write-Host "           KẾT QUẢ CÀI ĐẶT" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  Vị trí cài đặt  : $basePath" -ForegroundColor White
Write-Host "  Tổng số công ty : $($companyCodes.Count)" -ForegroundColor White
Write-Host "  Thư mục tạo mới : $($stats.FoldersCreated)" -ForegroundColor Green
Write-Host "  Thư mục đã có   : $($stats.FoldersSkipped)" -ForegroundColor Gray
Write-Host "  Copy thành công : $($stats.DataCopied)" -ForegroundColor Green
Write-Host "  Copy thất bại   : $($stats.DataFailed)" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Magenta

if ($stats.DataCopied -gt 0) {
    Write-Host "✔ CÀI ĐẶT HOÀN TẤT!" -ForegroundColor Green
} else {
    Write-Host "⚠ CÓ LỖI XẢY RA. Vui lòng kiểm tra lại!" -ForegroundColor Yellow
}

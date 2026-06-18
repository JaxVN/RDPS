# =============================================
# Allow all .exe in C:\FAST - Firewall Rules
# Dùng cho Action1 tải từ GitHub
# =============================================

$BasePath = "C:\FAST"
$TempPath = "$BasePath\Temp"
$LogPath  = "$TempPath\FAST_Firewall_Rules.log"
$Description = "Cho phép file exe trong thu muc FAST - Deploy by Action1"

# Tạo thư mục Temp nếu chưa có
if (-not (Test-Path $TempPath)) {
    New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
}

# Hàm ghi log
function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time | $Message" | Out-File $LogPath -Append -Encoding UTF8
}

try {
    Write-Log "=== BẮT ĐẦU SCRIPT ==="
    Write-Log "Thư mục gốc: $BasePath"

    if (-not (Test-Path $BasePath)) {
        Write-Log "ERROR: Thư mục $BasePath không tồn tại!"
        exit 1
    }

    # Xóa rule cũ (tránh trùng lặp)
    Get-NetFirewallRule | 
        Where-Object { $_.DisplayName -like "FAST*" -or $_.DisplayName -like "Allow FAST*" } | 
        Remove-NetFirewallRule -ErrorAction SilentlyContinue
    
    Write-Log "Đã xóa các rule FAST cũ"

    # Lấy tất cả file .exe trong C:\FAST (kể cả thư mục con)
    $exes = Get-ChildItem -Path $BasePath -Filter *.exe -Recurse -ErrorAction Stop

    $count = 0
    foreach ($exe in $exes) {
        $exeName = $exe.Name
        $exePath = $exe.FullName

        # Inbound Rule
        New-NetFirewallRule -DisplayName "FAST Inbound - $exeName" `
            -Direction Inbound `
            -Program $exePath `
            -Action Allow `
            -Profile Any `
            -Description $Description -ErrorAction SilentlyContinue | Out-Null

        # Outbound Rule
        New-NetFirewallRule -DisplayName "FAST Outbound - $exeName" `
            -Direction Outbound `
            -Program $exePath `
            -Action Allow `
            -Profile Any `
            -Description $Description -ErrorAction SilentlyContinue | Out-Null

        Write-Log "✓ Đã tạo rule cho: $exeName"
        $count++
    }

    Write-Log "HOÀN TẤT! Đã tạo firewall rules cho $count file .exe"
    Write-Log "=== KẾT THÚC SCRIPT ==="

    Write-Host "Hoàn tất! Log được lưu tại: $LogPath" -ForegroundColor Green

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Host "Lỗi xảy ra! Vui lòng kiểm tra log." -ForegroundColor Red
    exit 1
}

# =============================================
# Allow all .exe in C:\FAST - Firewall Rules
# Deploy qua Action1
# =============================================

$BasePath   = "C:\FAST"
$TempPath   = "$BasePath\Temp"
$LogPath    = "$TempPath\FAST_Firewall_Rules.log"
$Description = "Cho phep file exe trong thu muc FAST - Deploy by Action1"

# Tao thu muc Temp neu chua co
if (-not (Test-Path $TempPath)) {
    New-Item -Path $TempPath -ItemType Directory -Force | Out-Null
}

# Ham ghi log
function Write-Log {
    param([string]$Message)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time | $Message" | Out-File $LogPath -Append -Encoding UTF8
}

try {
    Write-Log "=== BAT DAU SCRIPT ==="
    Write-Log "Thu muc: $BasePath"

    if (-not (Test-Path $BasePath)) {
        Write-Log "ERROR: Thu muc $BasePath khong ton tai!"
        exit 1
    }

    # Lay tat ca file .exe
    $exes = Get-ChildItem -Path $BasePath -Filter *.exe -Recurse -ErrorAction Stop
    $count = $exes.Count

    Write-Log "Tim thay $count file .exe"

    if ($count -eq 0) {
        Write-Log "WARNING: Khong tim thay file .exe nao!"
        Write-Log "=== KET THUC SCRIPT ==="
        exit 0
    }

    # Xoa rule cu
    Get-NetFirewallRule | 
        Where-Object { $_.DisplayName -like "FAST*" } | 
        Remove-NetFirewallRule -ErrorAction SilentlyContinue
    
    Write-Log "Da xoa rule FAST cu"

    # Tao rule moi
    foreach ($exe in $exes) {
        $exeName = $exe.Name
        $exePath = $exe.FullName

        # Inbound Rule
        New-NetFirewallRule -DisplayName "FAST Inbound - $exeName" `
            -Direction Inbound `
            -Program $exePath `
            -Action Allow `
            -Profile Any `
            -Description $Description `
            -ErrorAction SilentlyContinue | Out-Null

        # Outbound Rule
        New-NetFirewallRule -DisplayName "FAST Outbound - $exeName" `
            -Direction Outbound `
            -Program $exePath `
            -Action Allow `
            -Profile Any `
            -Description $Description `
            -ErrorAction SilentlyContinue | Out-Null

        Write-Log "Da tao rule cho: $exeName"
    }

    Write-Log "HOAN TAT! Da tao rule cho $count file .exe ($($count*2) rules)"
    Write-Log "=== KET THUC SCRIPT ==="

} catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    exit 1
}

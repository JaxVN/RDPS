# ==============================================================================
# SCRIPT TỰ ĐỘNG TẢI, GIẢI NÉN, CẤU HÌNH SLIDESHOW & GHI LOG THEO CHUẨN KIENA
# ==============================================================================

# 1. ĐỊNH NGHĨA ĐƯỜNG DẪN VÀ FILE LOG
$PublicPictures = "C:\Users\Public\Pictures"
$LogPath = "$PublicPictures\KAG_Slideshow_Setup.log"
$ZipPath = "$PublicPictures\S.zip"
$ExtractPath = $PublicPictures
$GitHubUrl = "https://github.com/JaxVN/RMC/raw/main/S.zip"

# Hàm hỗ trợ ghi log nhanh kèm thời gian
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine = "[$TimeStamp] [$Level] $Message"
    Write-Output $LogLine
    Add-Content -Path $LogPath -Value $LogLine -Force
}

# Khởi tạo thư mục và file log mới (Ghi đè hoặc tạo mới file log cho đợt chạy này)
if (!(Test-Path $PublicPictures)) { New-Item -ItemType Directory -Force -Path $PublicPictures | Out-Null }
"==============================================================================" | Out-File $LogPath -Force
Write-Log "SETUP BACKGROUND AND SCREENLOCK" "START"

# 2. TIẾN HÀNH TẢI FILE S.ZIP TỪ GITHUB
Write-Log "Dang tai file S.zip tu GitHub..."
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $GitHubUrl -OutFile $ZipPath -UseBasicParsing -TimeoutSec 60
    Write-Log "Tai file S.zip tu GitHub thanh cong."
} catch {
    Write-Log "Loi khi tai file tu GitHub: $_" "ERROR"
    Exit 1
}

# 3. GIẢI NÉN FILE S.ZIP
Write-Log "Dang xu ly thu muc va giai nen..."
try {
    $OldSFolder = "$PublicPictures\S"
    if (Test-Path $OldSFolder) { 
        Remove-Item -Path $OldSFolder -Recurse -Force | Out-Null 
        Write-Log "Da xoa thu muc S cu de chuan bi ghi de."
    }

    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force
    Write-Log "Giai nen file S.zip vao $PublicPictures thanh cong."

    if (Test-Path $ZipPath) { Remove-Item -Path $ZipPath -Force | Out-Null }
} catch {
    Write-Log "Loi trong qua trinh giai nen file: $_" "ERROR"
    Exit 1
}

# 4. KIỂM TRA ĐƯỜNG DẪN ẢNH SAU KHI GIẢI NÉN
$DS_Path = "$PublicPictures\S\DS"
$LS_Path = "$PublicPictures\S\LS"

if (!(Test-Path $DS_Path) -or !(Test-Path $LS_Path)) {
    Write-Log "Cau truc file zip khong dung. Khong tim thay thu muc S\DS hoac S\LS!" "ERROR"
    Exit 1
}

# 5. CẤU HÌNH DESKTOP BACKGROUND SLIDESHOW
Write-Log "Dang cau hinh Registry cho Desktop Background Slideshow..."
try {
    $RegistryDesktop = "HKCU:\Control Panel\Desktop"
    if (Test-Path $RegistryDesktop) {
        Set-ItemProperty -Path $RegistryDesktop -Name "WallpaperStyle" -Value "10" -Force
        Set-ItemProperty -Path $RegistryDesktop -Name "TileWallpaper" -Value "0" -Force
    }

    $UserBackgroundPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers"
    if (!(Test-Path $UserBackgroundPath)) { New-Item -Path $UserBackgroundPath -Force | Out-Null }
    Set-ItemProperty -Path $UserBackgroundPath -Name "BackgroundType" -Value 2 -Force

    $ThemePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (Test-Path $ThemePath) {
        Set-ItemProperty -Path $ThemePath -Name "WallpaperSource" -Value $DS_Path -Force
    }
    Write-Log "Cau hinh Desktop Background Slideshow thanh cong."
} catch {
    Write-Log "Loi khi cau hinh Desktop Background: $_" "WARNING"
}

# 6. CẤU HÌNH LOCK SCREEN SLIDESHOW (Áp dụng hệ thống qua PersonalizationCSP)
Write-Log "Dang cau hinh PersonalizationCSP cho Lock Screen Slideshow..."
try {
    $CSPPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
    if (!(Test-Path $CSPPath)) { New-Item -Path $CSPPath -Force | Out-Null }

    Set-ItemProperty -Path $CSPPath -Name "LockScreenImageStatus" -Value 3 -Force
    Set-ItemProperty -Path $CSPPath -Name "LockScreenImagePath" -Value $LS_Path -Force
    Set-ItemProperty -Path $CSPPath -Name "LockScreenImageUrl" -Value $LS_Path -Force

    Set-ItemProperty -Path $CSPPath -Name "DesktopImageStatus" -Value 3 -Force
    Set-ItemProperty -Path $CSPPath -Name "DesktopImagePath" -Value $DS_Path -Force
    Set-ItemProperty -Path $CSPPath -Name "DesktopImageUrl" -Value $DS_Path -Force
    Write-Log "Cau hinh PersonalizationCSP thanh cong."
} catch {
    Write-Log "Loi khi cau hinh PersonalizationCSP: $_" "ERROR"
    Exit 1
}

# 7. THIẾT LẬP THỜI GIAN CHUYỂN ẢNH VÀ TẮT SHUFFLE (30 phút, Shuffle: Off)
try {
    $SlideshowPath = "HKCU:\Control Panel\Personalization\Desktop Slideshow"
    if (!(Test-Path $SlideshowPath)) { New-Item -Path $SlideshowPath -Force | Out-Null }
    Set-ItemProperty -Path $SlideshowPath -Name "Interval" -Value 1800000 -Force
    Set-ItemProperty -Path $SlideshowPath -Name "Shuffle" -Value 0 -Force
    Write-Log "Thiet lap thoi gian 30 phut va tat Shuffle thanh cong."
} catch {
    Write-Log "Loi khi thiet lap thoi gian Slideshow: $_" "WARNING"
}

# 8. REFRESH HỆ THỐNG ĐỂ ÁP DỤNG NGAY
Write-Log "Dang goi API SystemParametersInfo de lam moi giao dien..."
try {
    $Definition = @"
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern int SystemParametersInfo(int uAction, int uParam, string lvParam, int fuWinIni);
"@
    $API = Add-Type -MemberDefinition $Definition -Name "Win32SystemParametersInfo" -Namespace "Win32Utils" -PassThru

    $FirstImg = (Get-ChildItem -Path $DS_Path -Filter *.jpg | Select-Object -First 1).FullName
    if ($FirstImg) {
        $API::SystemParametersInfo(0x0014, 0, $FirstImg, 0x01 -bor 0x02)
    }
    Write-Log "TIEN TRINH HOAN THANH XUAT SAC!" "SUCCESS"
} catch {
    Write-Log "Khong the force refresh giao dien ngay lap tuc: $_. Thay doi se ap dung khi user Re-log." "WARNING"
}
"==============================================================================" | Add-Type -Path $LogPath -ErrorAction SilentlyContinue

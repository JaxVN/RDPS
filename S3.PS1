# ==============================================================================
# SCRIPT TỰ ĐỘNG TẢI, GIẢI NÉN, CẤU HÌNH SLIDESHOW & GHI LOG THEO CHUẨN KIENA
# ==============================================================================

# 1. ĐỊNH NGHĨA ĐƯỜNG DẪN VÀ FILE LOG
$PublicPictures = "C:\Users\Public\Pictures"
$LogPath = "$PublicPictures\KAG_Slideshow_Setup.log"
$ZipPath = "$PublicPictures\S.zip"
$ExtractPath = $PublicPictures
$GitHubUrl = "https://github.com/JaxVN/RMC/raw/main/S.zip"

# ============================================================================
# BƯỚC 0: KHỞI TẠO THỰC THƯ MỤC TRƯỚC KHI GHI LOG
# ============================================================================
Write-Host "🔍 Kiểm tra và tạo thư mục..." -ForegroundColor Cyan

if (!(Test-Path $PublicPictures)) {
    try {
        New-Item -ItemType Directory -Force -Path $PublicPictures | Out-Null
        Write-Host "✅ Tạo thư mục: $PublicPictures" -ForegroundColor Green
    } catch {
        Write-Host "❌ FATAL: Không thể tạo thư mục $PublicPictures" -ForegroundColor Red
        Write-Host "   Lỗi: $_" -ForegroundColor Red
        exit 1
    }
}

# Đảm bảo thư mục tồn tại trước khi dùng Out-File
if (!(Test-Path $PublicPictures)) {
    Write-Host "❌ FATAL: Thư mục vẫn không tồn tại sau khi tạo!" -ForegroundColor Red
    exit 1
}

# ============================================================================
# HÀM GHI LOG
# ============================================================================
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO"
    )
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogLine = "[$TimeStamp] [$Level] $Message"
    Write-Output $LogLine
    
    try {
        Add-Content -Path $LogPath -Value $LogLine -Force -ErrorAction Stop
    } catch {
        Write-Host "⚠️  Warning: Không thể ghi log: $_" -ForegroundColor Yellow
    }
}

# ============================================================================
# KHỞI TẠO FILE LOG
# ============================================================================
try {
    "==============================================================================" | Out-File $LogPath -Force -ErrorAction Stop
    Write-Host "✅ File log: $LogPath" -ForegroundColor Green
} catch {
    Write-Host "❌ FATAL: Không thể tạo file log: $_" -ForegroundColor Red
    exit 1
}

Write-Log "SETUP BACKGROUND AND SCREENLOCK" "START"

# ============================================================================
# 2. TIẾN HÀNH TẢI FILE S.ZIP TỪ GITHUB
# ============================================================================
Write-Log "Dang tai file S.zip tu GitHub..."
Write-Host "🌐 Đang tải S.zip từ GitHub..." -ForegroundColor Cyan

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    Invoke-WebRequest -Uri $GitHubUrl -OutFile $ZipPath -UseBasicParsing -TimeoutSec 60 -ErrorAction Stop
    Write-Log "Tai file S.zip tu GitHub thanh cong."
    Write-Host "✅ Tải file thành công" -ForegroundColor Green
} catch {
    Write-Log "Loi khi tai file tu GitHub: $_" "ERROR"
    Write-Host "❌ Lỗi tải file: $_" -ForegroundColor Red
    exit 1
}

# ============================================================================
# 3. GIẢI NÉN FILE S.ZIP
# ============================================================================
Write-Log "Dang xu ly thu muc va giai nen..."
Write-Host "📦 Đang giải nén file..." -ForegroundColor Cyan

try {
    $OldSFolder = "$PublicPictures\S"
    if (Test-Path $OldSFolder) { 
        Remove-Item -Path $OldSFolder -Recurse -Force -ErrorAction Stop | Out-Null 
        Write-Log "Da xoa thu muc S cu de chuan bi ghi de."
    }

    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force -ErrorAction Stop
    Write-Log "Giai nen file S.zip vao $PublicPictures thanh cong."
    Write-Host "✅ Giải nén thành công" -ForegroundColor Green

    if (Test-Path $ZipPath) { 
        Remove-Item -Path $ZipPath -Force -ErrorAction Stop | Out-Null 
    }
} catch {
    Write-Log "Loi trong qua trinh giai nen file: $_" "ERROR"
    Write-Host "❌ Lỗi giải nén: $_" -ForegroundColor Red
    exit 1
}

# ============================================================================
# 4. KIỂM TRA ĐƯỜNG DẪN ẢNH SAU KHI GIẢI NÉN
# ============================================================================
$DS_Path = "$PublicPictures\S\DS"
$LS_Path = "$PublicPictures\S\LS"

Write-Log "Kiem tra thu muc anh: DS=$DS_Path | LS=$LS_Path"

if (!(Test-Path $DS_Path)) {
    Write-Log "Khong tim thay thu muc DS: $DS_Path" "ERROR"
    Write-Host "❌ Lỗi: Không tìm thấy thư mục DS" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $LS_Path)) {
    Write-Log "Khong tim thay thu muc LS: $LS_Path" "ERROR"
    Write-Host "❌ Lỗi: Không tìm thấy thư mục LS" -ForegroundColor Red
    exit 1
}

Write-Log "✅ Cac thu muc anh da ton tai."
Write-Host "✅ Tìm thấy thư mục ảnh" -ForegroundColor Green

# ============================================================================
# 5. CẤU HÌNH DESKTOP BACKGROUND SLIDESHOW
# ============================================================================
Write-Log "Dang cau hinh Registry cho Desktop Background Slideshow..."
Write-Host "🖼️  Cấu hình Desktop Slideshow..." -ForegroundColor Cyan

try {
    $RegistryDesktop = "HKCU:\Control Panel\Desktop"
    if (Test-Path $RegistryDesktop) {
        Set-ItemProperty -Path $RegistryDesktop -Name "WallpaperStyle" -Value "10" -Force -ErrorAction Stop
        Set-ItemProperty -Path $RegistryDesktop -Name "TileWallpaper" -Value "0" -Force -ErrorAction Stop
    }

    $UserBackgroundPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers"
    if (!(Test-Path $UserBackgroundPath)) { 
        New-Item -Path $UserBackgroundPath -Force | Out-Null 
    }
    
    Set-ItemProperty -Path $UserBackgroundPath -Name "BackgroundType" -Value 2 -Force -ErrorAction Stop
    
    # FIX #1: BẬT SLIDESHOW TỰ ĐỘNG
    Set-ItemProperty -Path $UserBackgroundPath -Name "UseDesktopSlideshow" -Value 1 -Force -ErrorAction Stop
    Write-Log "Da bat Desktop Slideshow tu dong."

    $ThemePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (Test-Path $ThemePath) {
        Set-ItemProperty -Path $ThemePath -Name "WallpaperSource" -Value $DS_Path -Force -ErrorAction Stop
    }
    Write-Log "Cau hinh Desktop Background Slideshow thanh cong."
    Write-Host "✅ Cấu hình Desktop Slideshow thành công" -ForegroundColor Green
} catch {
    Write-Log "Loi khi cau hinh Desktop Background: $_" "WARNING"
    Write-Host "⚠️  Cảnh báo: Lỗi cấu hình Desktop: $_" -ForegroundColor Yellow
}

# ============================================================================
# 6. CẤU HÌNH LOCK SCREEN SLIDESHOW
# ============================================================================
Write-Log "Dang cau hinh PersonalizationCSP cho Lock Screen Slideshow..."
Write-Host "🔐 Cấu hình Lock Screen Slideshow..." -ForegroundColor Cyan

try {
    $CSPPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
    if (!(Test-Path $CSPPath)) { 
        New-Item -Path $CSPPath -Force | Out-Null 
    }

    Set-ItemProperty -Path $CSPPath -Name "LockScreenImageStatus" -Value 3 -Force -ErrorAction Stop
    Set-ItemProperty -Path $CSPPath -Name "LockScreenImagePath" -Value $LS_Path -Force -ErrorAction Stop
    Set-ItemProperty -Path $CSPPath -Name "LockScreenImageUrl" -Value $LS_Path -Force -ErrorAction Stop

    Set-ItemProperty -Path $CSPPath -Name "DesktopImageStatus" -Value 3 -Force -ErrorAction Stop
    Set-ItemProperty -Path $CSPPath -Name "DesktopImagePath" -Value $DS_Path -Force -ErrorAction Stop
    Set-ItemProperty -Path $CSPPath -Name "DesktopImageUrl" -Value $DS_Path -Force -ErrorAction Stop
    
    Write-Log "Cau hinh PersonalizationCSP thanh cong."
    Write-Host "✅ Cấu hình Lock Screen thành công" -ForegroundColor Green
} catch {
    Write-Log "Loi khi cau hinh PersonalizationCSP: $_" "ERROR"
    Write-Host "❌ Lỗi cấu hình Lock Screen: $_" -ForegroundColor Red
    exit 1
}

# ============================================================================
# 7. THIẾT LẬP THỜI GIAN CHUYỂN ẢNH VÀ TẮT SHUFFLE (30 phút, Shuffle: Off)
# ============================================================================
Write-Host "⏱️  Thiết lập thời gian slideshow (30 phút)..." -ForegroundColor Cyan

try {
    $SlideshowPath = "HKCU:\Control Panel\Personalization\Desktop Slideshow"
    if (!(Test-Path $SlideshowPath)) { 
        New-Item -Path $SlideshowPath -Force | Out-Null 
    }
    Set-ItemProperty -Path $SlideshowPath -Name "Interval" -Value 1800000 -Force -ErrorAction Stop
    Set-ItemProperty -Path $SlideshowPath -Name "Shuffle" -Value 0 -Force -ErrorAction Stop
    Write-Log "Thiet lap thoi gian 30 phut va tat Shuffle thanh cong."
    Write-Host "✅ Thiết lập thời gian thành công" -ForegroundColor Green
} catch {
    Write-Log "Loi khi thiet lap thoi gian Slideshow: $_" "WARNING"
    Write-Host "⚠️  Cảnh báo: Lỗi thiết lập thời gian: $_" -ForegroundColor Yellow
}

# ============================================================================
# 8. REFRESH HỆ THỐNG ĐỂ ÁP DỤNG NGAY
# ============================================================================
Write-Log "Dang goi API SystemParametersInfo de lam moi giao dien..."
Write-Host "🔄 Làm mới giao diện..." -ForegroundColor Cyan

try {
    $Definition = @"
[DllImport("user32.dll", CharSet = CharSet.Auto)]
public static extern int SystemParametersInfo(int uAction, int uParam, string lvParam, int fuWinIni);
"@
    $API = Add-Type -MemberDefinition $Definition -Name "Win32SystemParametersInfo" -Namespace "Win32Utils" -PassThru -ErrorAction Stop

    $FirstImg = (Get-ChildItem -Path $DS_Path -Filter *.jpg -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
    if ($FirstImg) {
        $API::SystemParametersInfo(0x0014, 0, $FirstImg, 0x01 -bor 0x02)
        Write-Log "Refresh giao dien thanh cong voi anh: $FirstImg"
        Write-Host "✅ Làm mới giao diện thành công" -ForegroundColor Green
    } else {
        Write-Log "Khong tim thay file anh JPG trong thu muc $DS_Path" "WARNING"
        Write-Host "⚠️  Cảnh báo: Không tìm thấy file ảnh JPG" -ForegroundColor Yellow
    }
    Write-Log "TIEN TRINH HOAN THANH XUAT SAC!" "SUCCESS"
} catch {
    Write-Log "Khong the force refresh giao dien ngay lap tuc: $_. Thay doi se ap dung khi user Re-log." "WARNING"
    Write-Host "⚠️  Cảnh báo: Không thể refresh ngay (sẽ áp dụng khi đăng nhập lại)" -ForegroundColor Yellow
}

# ============================================================================
# HOÀN TẤT SCRIPT
# ============================================================================
Write-Log "=========================================================================="
Add-Content -Path $LogPath -Value "===========================================================================" -Force

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "🎉 HOÀN TẤT SETUP THÀNH CÔNG!" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Chi tiết cấu hình:" -ForegroundColor Cyan
Write-Host "   • Desktop Slideshow: 30 phút/lần" -ForegroundColor White
Write-Host "   • Lock Screen: Bật với ảnh từ $LS_Path" -ForegroundColor White
Write-Host "   • Thư mục ảnh Desktop: $DS_Path" -ForegroundColor White
Write-Host "   • File log: $LogPath" -ForegroundColor White
Write-Host ""
Write-Host "⏰ Lưu ý: Một số thay đổi sẽ áp dụng hoàn toàn sau khi đăng nhập lại" -ForegroundColor Yellow
Write-Host ""

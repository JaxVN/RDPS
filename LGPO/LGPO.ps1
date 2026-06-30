# Định nghĩa đường dẫn tải file từ SharePoint (thay thế bằng URL thực tế)

$url = "https://github.com/JaxVN/LGPO/blob/main/LGPO.zip"  # Thay thế bằng đường dẫn thực tế đến file ATL_FA12.Zip +"&download=1" 

# Đường dẫn lưu file zip và thư mục đích
$zipPath = "C:\Soft\LGPO.Zip"
$extractPath = "C:\Soft"

# Tạo thư mục C:\Soft nếu chưa tồn tại
if (-not (Test-Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force
}

# Bước 1: Tải file nén từ SharePoint về C:\Soft
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Bước 2: Giải nén file LGPO.Zip vào C:\Soft
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Xóa file zip sau khi giải nén (tùy chọn)
Remove-Item -Path $zipPath -Force

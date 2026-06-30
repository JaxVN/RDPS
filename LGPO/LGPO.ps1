# Định nghĩa đường dẫn tải file từ SharePoint (thay thế bằng URL thực tế)

$url = "blob:https://github.com/1a2c16f5-e4f1-48b7-8138-3587643ccc89"  # 

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

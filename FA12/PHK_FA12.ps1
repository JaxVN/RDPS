# Định nghĩa đường dẫn tải file từ SharePoint (thay thế bằng URL thực tế)

$url = "https://kaglav.sharepoint.com/:u:/s/IT/IQD15yqVeKz1SI8nrah5hGIFAZ9CDmUA1b7D71AtD2K6vLU?e=iSVsW8&download=1"  # Thay thế bằng đường dẫn thực tế đến file KIA_FA12.Zip +"&download=1" 

# Đường dẫn lưu file zip và thư mục đích
$zipPath = "C:\FAST\KIA_FA12.Zip"
$extractPath = "C:\FAST"

# Tạo thư mục C:\FAST nếu chưa tồn tại
if (-not (Test-Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath -Force
}

# Bước 1: Tải file nén từ SharePoint về C:\FAST
Invoke-WebRequest -Uri $url -OutFile $zipPath

# Bước 2: Giải nén file KIA_FA12.Zip vào C:\FAST
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Bước 3: Copy shortcut ra thư mục Public Desktop
# Giả sử tên shortcut là "FAST.lnk" (thay thế bằng tên thực tế nếu khác)
$shortcutName = "KIA_FA12.lnk"  # Thay thế bằng tên shortcut thực tế trong file nén
$shortcutPath = Join-Path -Path $extractPath -ChildPath $shortcutName  # Shortcut nằm trực tiếp trong C:\FAST sau giải nén
$publicDesktop = "C:\Users\Public\Desktop"

if (Test-Path $shortcutPath) {
    Copy-Item -Path $shortcutPath -Destination $publicDesktop -Force
} else {
    Write-Error "Shortcut không tìm thấy tại $shortcutPath"
}

# Xóa file zip sau khi giải nén (tùy chọn)
Remove-Item -Path $zipPath -Force

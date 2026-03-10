# ============================
# Set-HomeButton-EdgeChrome.ps1
# Bật nút Home và trỏ về SharePoint cho Microsoft Edge & Google Chrome (policy-level)
# Yêu cầu: Run PowerShell as Administrator
# ============================

$homepage = "https://kienacorp.sharepoint.com/"

function Ensure-Key($path) {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
}

# -------- Microsoft Edge (Chromium) --------
$edgePath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
Ensure-Key $edgePath

# Hiển thị nút Home
New-ItemProperty -Path $edgePath -Name "ShowHomeButton" -PropertyType DWord -Value 1 -Force | Out-Null

# Đặt Home page (khi bấm nút Home sẽ tới trang này)
New-ItemProperty -Path $edgePath -Name "HomepageLocation" -PropertyType String -Value $homepage -Force | Out-Null
New-ItemProperty -Path $edgePath -Name "HomepageIsNewTabPage" -PropertyType DWord -Value 0 -Force | Out-Null

# (Không chỉnh Startup để giữ nguyên tuỳ chọn "Open tabs from the previous session" nếu người dùng đã bật)
# Nếu muốn ép mở Intranet mỗi lần khởi động Edge, bỏ chú thích 3 dòng dưới đây:
# New-ItemProperty -Path $edgePath -Name "RestoreOnStartup" -PropertyType DWord -Value 4 -Force | Out-Null
# $edgeStartup = "HKLM:\SOFTWARE\Policies\Microsoft\Edge\RestoreOnStartupURLs"
# Ensure-Key $edgeStartup; New-ItemProperty -Path $edgeStartup -Name "1" -PropertyType String -Value $homepage -Force | Out-Null

# -------- Google Chrome --------
$chromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"
Ensure-Key $chromePath

# Hiển thị nút Home
New-ItemProperty -Path $chromePath -Name "ShowHomeButton" -PropertyType DWord -Value 1 -Force | Out-Null

# Đặt Home page (nút Home về SharePoint)
New-ItemProperty -Path $chromePath -Name "HomepageLocation" -PropertyType String -Value $homepage -Force | Out-Null
New-ItemProperty -Path $chromePath -Name "HomepageIsNewTabPage" -PropertyType DWord -Value 0 -Force | Out-Null

#Write-Host "DONE: Đã bật Home button & đặt trang SharePoint cho Edge & Chrome (policy-level - HKLM)."
#Write-Host "Kiểm tra: edge://policy và chrome://policy → Reload; khởi động lại trình duyệt nếu cần."

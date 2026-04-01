#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Buộc Microsoft Edge làm trình duyệt mặc định bằng XML (phiên bản sửa lỗi)
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ScriptName = "Set-EdgeAsDefaultBrowser"
$ScriptVersion = "1.2.0"

Write-Host "=== $ScriptName v$ScriptVersion - BUỘC EDGE LÀM TRÌNH DUYỆT MẶC ĐỊNH ===" -ForegroundColor Cyan
Write-Host ""

$XMLPath = "C:\Windows\EdgeDefaultAssociations.xml"
$RegSystem = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
$RegExplorer = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer"

# === Tạo file XML ===
$XMLContent = @'
<?xml version="1.0" encoding="UTF-8"?>
<DefaultAssociations>
    <Association ApplicationName="Microsoft Edge" ProgId="MSEdgeHTM" Identifier=".html"/>
    <Association ApplicationName="Microsoft Edge" ProgId="MSEdgeHTM" Identifier=".htm"/>
    <Association ApplicationName="Microsoft Edge" ProgId="MSEdgeHTM" Identifier="http"/>
    <Association ApplicationName="Microsoft Edge" ProgId="MSEdgeHTM" Identifier="https"/>    
</DefaultAssociations>
'@

$XMLContent | Out-File -FilePath $XMLPath -Encoding UTF8 -Force
Write-Host "✓ Đã tạo file XML tại: $XMLPath" -ForegroundColor Green

# === Tạo các key registry trước khi set ===
$PathsToCreate = @($RegSystem, $RegExplorer)
foreach ($path in $PathsToCreate) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
        Write-Host "✓ Đã tạo key: $path" -ForegroundColor Gray
    }
}

# === Áp dụng DefaultAssociationsConfiguration (quan trọng nhất) ===
Set-ItemProperty -Path $RegSystem -Name "DefaultAssociationsConfiguration" -Value $XMLPath -Type String -Force
Write-Host "✓ Đã áp dụng DefaultAssociationsConfiguration (Edge sẽ là mặc định)" -ForegroundColor Green

# === Các policy hỗ trợ khác ===
Set-ItemProperty -Path $RegExplorer -Name "NoUseStoreOpenWith" -Value 1 -Type DWORD -Force
Write-Host "✓ Đã chặn mở Microsoft Store khi chọn Open with" -ForegroundColor Green

Set-ItemProperty -Path $RegSystem -Name "NoNewAppAlert" -Value 1 -Type DWORD -Force
Write-Host "✓ Đã tắt thông báo 'New app installed'" -ForegroundColor Green

Write-Host ""
Write-Host "-----------------------------------------" -ForegroundColor DarkGray
Write-Host "HOÀN TẤT! Microsoft Edge đã được buộc làm trình duyệt mặc định." -ForegroundColor Green
Write-Host "• Thay đổi sẽ áp dụng tốt nhất sau khi **khởi động lại máy**." -ForegroundColor Yellow
Write-Host "• Người dùng vẫn có thể tạm thay đổi, nhưng sẽ bị reset khi đăng nhập lại." -ForegroundColor Yellow
Write-Host "-----------------------------------------" -ForegroundColor DarkGray
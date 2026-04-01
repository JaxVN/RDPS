#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Bật chế độ chặn OneDrive cá nhân (Personal Account Restrictions)
.DESCRIPTION
    Áp dụng các policy để chặn đăng nhập, đồng bộ OneDrive cá nhân.
    - DisablePersonalSync (HKCU)     : Chặn hoàn toàn tài khoản cá nhân
    - DisableNewAccountDetection (HKLM): Ẩn prompt "Add personal account"
    - KFMBlockOptIn (HKLM)           : Chặn Known Folder Move sang cá nhân
.NOTES
    RDPS Script Pair : Set-OneDrivePersonalRestrictions / Remove-OneDrivePersonalRestrictions
    Author : PCS Vietnam — JaxVN (cập nhật 2026)
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ScriptName = "Set-OneDrivePersonalRestrictions"
$ScriptVersion = "1.1.0"

Write-Host "=== $ScriptName v$ScriptVersion - BẬT CHẾ ĐỘ CHẶN ONEDRIVE CÁ NHÂN ===" -ForegroundColor Cyan
Write-Host ""

# Đường dẫn Registry
$RegHKCU = "HKCU:\SOFTWARE\Policies\Microsoft\OneDrive"
$RegHKLM = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"

# Tạo key nếu chưa có
foreach ($path in @($RegHKCU, $RegHKLM)) {
    if (-not (Test-Path $path)) {
        if ($PSCmdlet.ShouldProcess($path, "Create registry key")) {
            New-Item -Path $path -Force | Out-Null
        }
    }
}

$Policies = @(
    @{ Path = $RegHKCU; Name = "DisablePersonalSync";        Value = 1; Type = "DWORD"; Desc = "Chặn đăng nhập & đồng bộ tài khoản OneDrive cá nhân" },
    @{ Path = $RegHKLM; Name = "DisableNewAccountDetection"; Value = 1; Type = "DWORD"; Desc = "Ẩn thông báo gợi ý thêm tài khoản cá nhân" },
    @{ Path = $RegHKLM; Name = "KFMBlockOptIn";              Value = 1; Type = "DWORD"; Desc = "Chặn Known Folder Move (Desktop/Documents) sang OneDrive cá nhân" }
)

$Applied = 0
foreach ($p in $Policies) {
    Write-Host "Áp dụng: $($p.Desc)" -ForegroundColor White
    if ($PSCmdlet.ShouldProcess("$($p.Path)\$($p.Name)", "Set = $($p.Value)")) {
        Set-ItemProperty -Path $p.Path -Name $p.Name -Value $p.Value -Type $p.Type -Force
        Write-Host "   ✓ Đã áp dụng $($p.Name) = $($p.Value)" -ForegroundColor Green
        $Applied++
    }
}

Write-Host ""
Write-Host "-----------------------------------------" -ForegroundColor DarkGray
Write-Host "HOÀN TẤT! ĐÃ BẬT CHẾ ĐỘ CHẶN ONEDRIVE CÁ NHÂN" -ForegroundColor Green
Write-Host "• Tài khoản cá nhân sẽ bị ngắt kết nối và không thể đăng nhập lại" -ForegroundColor Yellow
Write-Host "• Prompt gợi ý thêm tài khoản cá nhân bị ẩn" -ForegroundColor Yellow
Write-Host ""
Write-Host "Khuyến nghị: Khởi động lại máy hoặc Restart OneDrive để áp dụng đầy đủ." -ForegroundColor DarkYellow
Write-Host "-----------------------------------------" -ForegroundColor DarkGray
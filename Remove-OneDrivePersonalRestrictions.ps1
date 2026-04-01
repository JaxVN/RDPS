#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Tắt chế độ chặn OneDrive cá nhân (Remove Personal Account Restrictions)
.DESCRIPTION
    Xóa các policy đã đặt để cho phép sử dụng OneDrive cá nhân bình thường trở lại.
.NOTES
    RDPS Script Pair : Set-OneDrivePersonalRestrictions / Remove-OneDrivePersonalRestrictions
    Author : PCS Vietnam — JaxVN (cập nhật 2026)
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ScriptName = "Remove-OneDrivePersonalRestrictions"
$ScriptVersion = "1.1.0"

Write-Host "=== $ScriptName v$ScriptVersion - TẮT CHẾ ĐỘ CHẶN ONEDRIVE CÁ NHÂN ===" -ForegroundColor Cyan
Write-Host ""

$RegHKCU = "HKCU:\SOFTWARE\Policies\Microsoft\OneDrive"
$RegHKLM = "HKLM:\SOFTWARE\Policies\Microsoft\OneDrive"

$Policies = @(
    @{ Path = $RegHKCU; Name = "DisablePersonalSync" },
    @{ Path = $RegHKLM; Name = "DisableNewAccountDetection" },
    @{ Path = $RegHKLM; Name = "KFMBlockOptIn" }
)

$Removed = 0
foreach ($p in $Policies) {
    if (Test-Path $p.Path) {
        $existing = Get-ItemProperty -Path $p.Path -Name $p.Name -ErrorAction SilentlyContinue
        if ($null -ne $existing) {
            if ($PSCmdlet.ShouldProcess("$($p.Path)\$($p.Name)", "Remove value")) {
                Remove-ItemProperty -Path $p.Path -Name $p.Name -Force -ErrorAction SilentlyContinue
                Write-Host "   ✓ Đã xóa $($p.Name)" -ForegroundColor Green
                $Removed++
            }
        } else {
            Write-Host "   - $($p.Name) không tồn tại" -ForegroundColor Gray
        }
    }
}

# Xóa key rỗng nếu cần
if (Test-Path $RegHKCU) {
    if ((Get-ChildItem $RegHKCU -ErrorAction SilentlyContinue).Count -eq 0) {
        Remove-Item $RegHKCU -Force -ErrorAction SilentlyContinue
    }
}
if (Test-Path $RegHKLM) {
    if ((Get-ChildItem $RegHKLM -ErrorAction SilentlyContinue).Count -eq 0) {
        Remove-Item $RegHKLM -Force -ErrorAction SilentlyContinue
    }
}

Write-Host ""
Write-Host "-----------------------------------------" -ForegroundColor DarkGray
Write-Host "HOÀN TẤT! ĐÃ TẮT CHẾ ĐỘ CHẶN ONEDRIVE CÁ NHÂN" -ForegroundColor Green
Write-Host "• Bạn có thể đăng nhập và đồng bộ tài khoản OneDrive cá nhân bình thường" -ForegroundColor Yellow
Write-Host ""
Write-Host "Khuyến nghị: Khởi động lại máy hoặc Restart OneDrive." -ForegroundColor DarkYellow
Write-Host "-----------------------------------------" -ForegroundColor DarkGray
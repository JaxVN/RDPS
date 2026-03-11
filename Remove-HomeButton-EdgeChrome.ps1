# Safe-Rollback-HomeButton-Only.ps1
$edgePath   = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$chromePath = "HKLM:\SOFTWARE\Policies\Google\Chrome"

function Remove-Prop($path, $name) {
    if ((Test-Path $path) -and (Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue)) {
        Remove-ItemProperty -Path $path -Name $name -Force -ErrorAction SilentlyContinue
    }
}

# Edge: chỉ gỡ các giá trị Home/Homepage
Remove-Prop $edgePath   "ShowHomeButton"
Remove-Prop $edgePath   "HomepageLocation"
Remove-Prop $edgePath   "HomepageIsNewTabPage"
# (Nếu trước đó bạn từng ép Startup thì bỏ comment 2 dòng dưới để gỡ nốt)
# Remove-Prop $edgePath   "RestoreOnStartup"
# if (Test-Path "$edgePath\RestoreOnStartupURLs"){ Remove-Item "$edgePath\RestoreOnStartupURLs" -Recurse -Force }

# Chrome: chỉ gỡ các giá trị Home/Homepage
Remove-Prop $chromePath "ShowHomeButton"
Remove-Prop $chromePath "HomepageLocation"
Remove-Prop $chromePath "HomepageIsNewTabPage"

#Write-Host "Đã rollback các thiết lập Home button/Homepage cho Edge & Chrome."

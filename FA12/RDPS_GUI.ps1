# ============================================================
#  RDPS GUI Launcher - Windows Forms
#  Chay trong user session (khong can admin)
#  GitHub: JaxVN/RDPS
# ============================================================

# Xu ly loi Unicode tren console cu
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ─────────────────────────────────────────────
#  DANH SACH SCRIPT - chinh sua tai day
# ─────────────────────────────────────────────
$Scripts = @(
    @{ Id=1;  Name="ATL FA12";     Desc="Script ATL FA12";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/FA12/ATL_FA12.ps1" },
    @{ Id=2;  Name="Script 02";    Desc="Mo ta script 02";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script02.ps1" },
    @{ Id=3;  Name="Script 03";    Desc="Mo ta script 03";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script03.ps1" },
    @{ Id=4;  Name="Script 04";    Desc="Mo ta script 04";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script04.ps1" },
    @{ Id=5;  Name="Script 05";    Desc="Mo ta script 05";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script05.ps1" },
    @{ Id=6;  Name="Script 06";    Desc="Mo ta script 06";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script06.ps1" },
    @{ Id=7;  Name="Script 07";    Desc="Mo ta script 07";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script07.ps1" },
    @{ Id=8;  Name="Script 08";    Desc="Mo ta script 08";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script08.ps1" },
    @{ Id=9;  Name="Script 09";    Desc="Mo ta script 09";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script09.ps1" },
    @{ Id=10; Name="Script 10";    Desc="Mo ta script 10";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script10.ps1" },
    @{ Id=11; Name="Script 11";    Desc="Mo ta script 11";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script11.ps1" },
    @{ Id=12; Name="Script 12";    Desc="Mo ta script 12";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script12.ps1" },
    @{ Id=13; Name="Script 13";    Desc="Mo ta script 13";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script13.ps1" },
    @{ Id=14; Name="Script 14";    Desc="Mo ta script 14";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script14.ps1" },
    @{ Id=15; Name="Script 15";    Desc="Mo ta script 15";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script15.ps1" },
    @{ Id=16; Name="Script 16";    Desc="Mo ta script 16";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script16.ps1" },
    @{ Id=17; Name="Script 17";    Desc="Mo ta script 17";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script17.ps1" },
    @{ Id=18; Name="Script 18";    Desc="Mo ta script 18";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script18.ps1" },
    @{ Id=19; Name="Script 19";    Desc="Mo ta script 19";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script19.ps1" },
    @{ Id=20; Name="Script 20";    Desc="Mo ta script 20";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script20.ps1" },
    @{ Id=21; Name="Script 21";    Desc="Mo ta script 21";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script21.ps1" },
    @{ Id=22; Name="Script 22";    Desc="Mo ta script 22";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script22.ps1" },
    @{ Id=23; Name="Script 23";    Desc="Mo ta script 23";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script23.ps1" },
    @{ Id=24; Name="Script 24";    Desc="Mo ta script 24";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script24.ps1" },
    @{ Id=25; Name="Script 25";    Desc="Mo ta script 25";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script25.ps1" },
    @{ Id=26; Name="Script 26";    Desc="Mo ta script 26";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script26.ps1" },
    @{ Id=27; Name="Script 27";    Desc="Mo ta script 27";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script27.ps1" },
    @{ Id=28; Name="Script 28";    Desc="Mo ta script 28";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script28.ps1" },
    @{ Id=29; Name="Script 29";    Desc="Mo ta script 29";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script29.ps1" },
    @{ Id=30; Name="Script 30";    Desc="Mo ta script 30";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script30.ps1" },
    @{ Id=31; Name="Script 31";    Desc="Mo ta script 31";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script31.ps1" },
    @{ Id=32; Name="Script 32";    Desc="Mo ta script 32";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script32.ps1" },
    @{ Id=33; Name="Script 33";    Desc="Mo ta script 33";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script33.ps1" },
    @{ Id=34; Name="Script 34";    Desc="Mo ta script 34";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script34.ps1" },
    @{ Id=35; Name="Script 35";    Desc="Mo ta script 35";    Url="https://raw.githubusercontent.com/JaxVN/RDPS/refs/heads/main/script35.ps1" }
)

# ─────────────────────────────────────────────
#  MAU SAC & FONT
# ─────────────────────────────────────────────
$clrBg        = [System.Drawing.Color]::FromArgb(245, 247, 250)
$clrHeader    = [System.Drawing.Color]::FromArgb(30,  90,  180)
$clrBtnRun    = [System.Drawing.Color]::FromArgb(30,  90,  180)
$clrBtnRunHov = [System.Drawing.Color]::FromArgb(20,  70,  150)
$clrBtnSel    = [System.Drawing.Color]::FromArgb(230, 235, 245)
$clrSuccess   = [System.Drawing.Color]::FromArgb(39,  174, 96)
$clrError     = [System.Drawing.Color]::FromArgb(192, 57,  43)
$clrWarning   = [System.Drawing.Color]::FromArgb(230, 126, 34)
$clrLogBg     = [System.Drawing.Color]::FromArgb(30,  30,  30)
$clrLogText   = [System.Drawing.Color]::FromArgb(200, 200, 200)
$clrWhite     = [System.Drawing.Color]::White

$fontTitle    = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$fontSub      = New-Object System.Drawing.Font("Segoe UI", 8)
$fontNormal   = New-Object System.Drawing.Font("Segoe UI", 9)
$fontBold     = New-Object System.Drawing.Font("Segoe UI", 9,  [System.Drawing.FontStyle]::Bold)
$fontBtn      = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontLog      = New-Object System.Drawing.Font("Consolas", 8)

# ─────────────────────────────────────────────
#  FORM CHINH
# ─────────────────────────────────────────────
$form = New-Object System.Windows.Forms.Form
$form.Text            = "RDPS Tools Launcher"
$form.Size            = New-Object System.Drawing.Size(620, 700)
$form.StartPosition   = "CenterScreen"
$form.BackColor       = $clrBg
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false
$form.Font            = $fontNormal

# ── Header ──
$pnlHeader = New-Object System.Windows.Forms.Panel
$pnlHeader.Dock      = "Top"
$pnlHeader.Height    = 64
$pnlHeader.BackColor = $clrHeader

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text      = "  RDPS Tools Launcher"
$lblTitle.Font      = $fontTitle
$lblTitle.ForeColor = $clrWhite
$lblTitle.Dock      = "Fill"
$lblTitle.TextAlign = "MiddleLeft"

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text      = "  github.com/JaxVN/RDPS"
$lblSub.Font      = $fontSub
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(180, 210, 255)
$lblSub.Dock      = "Bottom"
$lblSub.Height    = 18
$lblSub.TextAlign = "BottomLeft"

$pnlHeader.Controls.Add($lblTitle)
$pnlHeader.Controls.Add($lblSub)

# ── Thanh cong cu chon ──
$pnlTools = New-Object System.Windows.Forms.Panel
$pnlTools.Height    = 36
$pnlTools.Dock      = "Top"
$pnlTools.BackColor = [System.Drawing.Color]::FromArgb(220, 228, 245)
$pnlTools.Padding   = New-Object System.Windows.Forms.Padding(8, 0, 8, 0)

$btnSelAll = New-Object System.Windows.Forms.Button
$btnSelAll.Text     = "Chon tat ca"
$btnSelAll.Size     = New-Object System.Drawing.Size(90, 26)
$btnSelAll.Location = New-Object System.Drawing.Point(8, 5)
$btnSelAll.FlatStyle = "Flat"
$btnSelAll.BackColor = $clrBtnSel
$btnSelAll.Font      = $fontNormal

$btnSelNone = New-Object System.Windows.Forms.Button
$btnSelNone.Text      = "Bo chon"
$btnSelNone.Size      = New-Object System.Drawing.Size(80, 26)
$btnSelNone.Location  = New-Object System.Drawing.Point(104, 5)
$btnSelNone.FlatStyle = "Flat"
$btnSelNone.BackColor = $clrBtnSel
$btnSelNone.Font      = $fontNormal

$lblCount = New-Object System.Windows.Forms.Label
$lblCount.Text      = "Da chon: 0"
$lblCount.Font      = $fontNormal
$lblCount.ForeColor = [System.Drawing.Color]::FromArgb(60, 90, 160)
$lblCount.Size      = New-Object System.Drawing.Size(200, 26)
$lblCount.Location  = New-Object System.Drawing.Point(200, 8)
$lblCount.TextAlign = "MiddleLeft"

$pnlTools.Controls.AddRange(@($btnSelAll, $btnSelNone, $lblCount))

# ── CheckedListBox ──
$pnlList = New-Object System.Windows.Forms.Panel
$pnlList.Dock    = "Top"
$pnlList.Height  = 370
$pnlList.Padding = New-Object System.Windows.Forms.Padding(8)

$clb = New-Object System.Windows.Forms.CheckedListBox
$clb.Dock             = "Fill"
$clb.CheckOnClick     = $true
$clb.Font             = $fontNormal
$clb.BackColor        = $clrWhite
$clb.BorderStyle      = "FixedSingle"
$clb.IntegralHeight   = $false
$clb.ItemHeight       = 22

foreach ($s in $Scripts) {
    $clb.Items.Add("[$($s.Id.ToString().PadLeft(2,'0'))]  $($s.Name)  —  $($s.Desc)") | Out-Null
}

$pnlList.Controls.Add($clb)

# ── Progress + Log ──
$pnlBottom = New-Object System.Windows.Forms.Panel
$pnlBottom.Dock    = "Fill"
$pnlBottom.Padding = New-Object System.Windows.Forms.Padding(8, 4, 8, 4)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Dock    = "Top"
$progressBar.Height  = 18
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value   = 0
$progressBar.Style   = "Continuous"

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Dock      = "Top"
$lblStatus.Height    = 20
$lblStatus.Text      = "San sang."
$lblStatus.Font      = $fontNormal
$lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 80)

$rtbLog = New-Object System.Windows.Forms.RichTextBox
$rtbLog.Dock        = "Fill"
$rtbLog.ReadOnly    = $true
$rtbLog.BackColor   = $clrLogBg
$rtbLog.ForeColor   = $clrLogText
$rtbLog.Font        = $fontLog
$rtbLog.BorderStyle = "None"
$rtbLog.ScrollBars  = "Vertical"

$pnlBottom.Controls.Add($rtbLog)
$pnlBottom.Controls.Add($lblStatus)
$pnlBottom.Controls.Add($progressBar)

# ── Nut RUN ──
$pnlRun = New-Object System.Windows.Forms.Panel
$pnlRun.Dock      = "Bottom"
$pnlRun.Height    = 52
$pnlRun.BackColor = $clrBg
$pnlRun.Padding   = New-Object System.Windows.Forms.Padding(8, 8, 8, 8)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text      = "CHAY SCRIPT DA CHON"
$btnRun.Dock      = "Fill"
$btnRun.Font      = $fontBtn
$btnRun.BackColor = $clrBtnRun
$btnRun.ForeColor = $clrWhite
$btnRun.FlatStyle = "Flat"
$btnRun.FlatAppearance.BorderSize = 0
$btnRun.Cursor    = [System.Windows.Forms.Cursors]::Hand

$pnlRun.Controls.Add($btnRun)

# ── Gan vao Form ──
$form.Controls.Add($pnlBottom)
$form.Controls.Add($pnlList)
$form.Controls.Add($pnlTools)
$form.Controls.Add($pnlHeader)
$form.Controls.Add($pnlRun)

# ─────────────────────────────────────────────
#  HAM TIEN ICH LOG
# ─────────────────────────────────────────────
function Write-Log {
    param([string]$Msg, [string]$Type = "INFO")
    $time  = Get-Date -Format "HH:mm:ss"
    $color = switch ($Type) {
        "OK"   { $clrSuccess }
        "ERR"  { $clrError   }
        "WARN" { $clrWarning }
        "HEAD" { [System.Drawing.Color]::FromArgb(100, 180, 255) }
        default { $clrLogText }
    }
    $rtbLog.SelectionStart  = $rtbLog.TextLength
    $rtbLog.SelectionLength = 0
    $rtbLog.SelectionColor  = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $rtbLog.AppendText("[$time] ")
    $rtbLog.SelectionColor = $color
    $rtbLog.AppendText("$Msg`n")
    $rtbLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

# ─────────────────────────────────────────────
#  SU KIEN
# ─────────────────────────────────────────────

# Cap nhat so luong da chon
$clb.Add_ItemCheck({
    $form.BeginInvoke([System.Action]{
        $lblCount.Text = "Da chon: $($clb.CheckedItems.Count)"
    }) | Out-Null
})

# Chon tat ca
$btnSelAll.Add_Click({
    for ($i = 0; $i -lt $clb.Items.Count; $i++) {
        $clb.SetItemChecked($i, $true)
    }
    $lblCount.Text = "Da chon: $($clb.CheckedItems.Count)"
})

# Bo chon
$btnSelNone.Add_Click({
    for ($i = 0; $i -lt $clb.Items.Count; $i++) {
        $clb.SetItemChecked($i, $false)
    }
    $lblCount.Text = "Da chon: 0"
})

# ── Nut RUN chu dao ──
$btnRun.Add_Click({
    $checkedIndices = @()
    for ($i = 0; $i -lt $clb.Items.Count; $i++) {
        if ($clb.GetItemChecked($i)) { $checkedIndices += $i }
    }

    if ($checkedIndices.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show(
            "Vui long chon it nhat 1 script truoc khi chay.",
            "Chua chon script",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        ) | Out-Null
        return
    }

    # Khoa UI trong khi chay
    $btnRun.Enabled    = $false
    $btnSelAll.Enabled = $false
    $btnSelNone.Enabled= $false
    $clb.Enabled       = $false

    $total = $checkedIndices.Count
    $done  = 0

    $progressBar.Maximum = $total
    $progressBar.Value   = 0

    $rtbLog.Clear()
    Write-Log "Bat dau chay $total script..." "HEAD"

    foreach ($idx in $checkedIndices) {
        $s = $Scripts[$idx]
        $done++

        $lblStatus.Text    = "($done/$total) Dang chay: $($s.Name)"
        $progressBar.Value = $done - 1
        [System.Windows.Forms.Application]::DoEvents()

        Write-Log ">> $($s.Name)" "HEAD"

        try {
            $resp  = Invoke-WebRequest -Uri $s.Url -UseBasicParsing -ErrorAction Stop
            $block = [ScriptBlock]::Create($resp.Content)

            # Bat stdout/stderr de hien trong log
            $output = & {
                $oldOut = [Console]::Out
                $oldErr = [Console]::Error
                $sw     = New-Object System.IO.StringWriter
                [Console]::SetOut($sw)
                [Console]::SetError($sw)
                try   { Invoke-Command -ScriptBlock $block -ErrorAction Stop }
                catch { $sw.WriteLine("LOI: $_") }
                finally {
                    [Console]::SetOut($oldOut)
                    [Console]::SetError($oldErr)
                }
                $sw.ToString()
            }

            if ($output) {
                foreach ($line in ($output -split "`n")) {
                    if ($line.Trim() -ne "") { Write-Log $line.Trim() "INFO" }
                }
            }

            Write-Log "[OK] $($s.Name) hoan thanh." "OK"

        } catch {
            Write-Log "[LOI] $($s.Name): $_" "ERR"
        }

        $progressBar.Value = $done
        [System.Windows.Forms.Application]::DoEvents()
    }

    $lblStatus.Text = "Hoan thanh $total script."
    Write-Log "────────────────────────────" "HEAD"
    Write-Log "Da chay xong tat ca $total script." "OK"

    # Mo khoa UI
    $btnRun.Enabled     = $true
    $btnSelAll.Enabled  = $true
    $btnSelNone.Enabled = $true
    $clb.Enabled        = $true
})

# ─────────────────────────────────────────────
#  CHAY FORM
# ─────────────────────────────────────────────
[System.Windows.Forms.Application]::EnableVisualStyles()
[void]$form.ShowDialog()

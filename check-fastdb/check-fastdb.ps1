$root = 'C:\FAST'
$out  = Join-Path $root '\Tools\FAST_current_port.csv'
$pc   = $env:COMPUTERNAME
$time = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

function Get-Val($text, $name) {
    $m = [regex]::Match($text, 'name="' + $name + '"\s+value="([^"]*)"')
    if ($m.Success) { $m.Groups[1].Value } else { '' }
}
function Get-Tag($text, $tag) {
    $m = [regex]::Match($text, "<$tag>([^<]*)</$tag>")
    if ($m.Success) { $m.Groups[1].Value } else { '' }
}

$rows = foreach ($d in Get-ChildItem -LiteralPath $root -Directory | Sort-Object Name) {
    $f = Join-Path $d.FullName 'fastdb.xml'
    if (-not (Test-Path -LiteralPath $f)) {
        [pscustomobject]@{
            May = $pc; ThuMuc = $d.Name; Port = ''; FastLoader = ''; Alias = ''
            DataSource = ''; Database = ''; TrangThai = 'KHONG CO fastdb.xml'
            DuongDan = $f; QuetLuc = $time
        }
        continue
    }
    $t = Get-Content -LiteralPath $f -Raw
    [pscustomobject]@{
        May        = $pc
        ThuMuc     = $d.Name
        Port       = Get-Val $t 'Port'
        FastLoader = Get-Val $t 'FastLoader'
        Alias      = Get-Val $t 'Alias'
        DataSource = Get-Tag $t 'DataSource'
        Database   = Get-Tag $t 'InitialCatalog'
        TrangThai  = ''
        DuongDan   = $f
        QuetLuc    = $time
    }
}

# Tính trạng thái: lệch Port/FastLoader, trùng Port giữa các thư mục
$dupPorts = $rows | Where-Object { $_.Port -ne '' } | Group-Object Port |
            Where-Object Count -gt 1 | ForEach-Object Name
foreach ($r in $rows) {
    if ($r.TrangThai -ne '') { continue }
    $s = @()
    if ($r.Port -eq '' -or $r.FastLoader -eq '') { $s += 'THIEU Port/FastLoader' }
    elseif ($r.Port -ne $r.FastLoader)           { $s += 'LECH Port/FastLoader' }
    if ($dupPorts -contains $r.Port)             { $s += 'TRUNG PORT' }
    $r.TrangThai = if ($s) { $s -join ' | ' } else { 'OK' }
}

$rows | Export-Csv -LiteralPath $out -NoTypeInformation -Encoding UTF8 -UseCulture
$rows | Format-Table May, ThuMuc, Port, FastLoader, Alias, Database, TrangThai -AutoSize
Write-Host "Da luu bao cao: $out" -ForegroundColor Green

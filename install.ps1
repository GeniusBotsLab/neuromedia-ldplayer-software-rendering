# Ставит Mesa 21.3.1 (llvmpipe, OpenGL 4.5) для LDPlayer 14 на сервере без видеокарты / по RDP.
#   Без параметров  — закрыть LD, удалить старые Mesa-файлы, поставить правильные (сам запросит админа).
#   -Check          — только показать, что сейчас стоит, ничего не менять.
param([switch]$Check)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path   # папка LDPlayer14-Mesa-Fix (рядом лежит mesa\x86 и mesa\x64)
$ld   = 'D:\LDPlayer\LDPlayer14'                          # dnplayer.exe — 32-бит  -> сюда x86 Mesa
$box  = 'C:\Program Files\ldplayer9box'                   # Ld9BoxHeadless.exe (рендер) — 64-бит -> сюда x64 Mesa
$files = 'opengl32.dll', 'libgallium_wgl.dll', 'libglapi.dll'
$targets = @(@{ Dir = $ld; Arch = 'x86' }, @{ Dir = $box; Arch = 'x64' })

function Get-Arch($path) {
    try {
        $fs = [IO.File]::OpenRead($path); $br = New-Object IO.BinaryReader($fs)
        $fs.Seek(0x3c, 0) | Out-Null; $off = $br.ReadInt32(); $fs.Seek($off + 4, 0) | Out-Null; $m = $br.ReadUInt16(); $fs.Close()
        if ($m -eq 0x14c) { 'x86' } elseif ($m -eq 0x8664) { 'x64' } else { '?' }
    } catch { '?' }
}

function Show-State {
    $allOk = $true
    foreach ($t in $targets) {
        Write-Host "`n[$($t.Dir)]  нужно: $($t.Arch)"
        if (-not (Test-Path $t.Dir)) { Write-Host '   !! папки нет — LDPlayer не установлен сюда?' -ForegroundColor Red; $allOk = $false; continue }
        $found = Get-ChildItem $t.Dir -Filter *.dll -ErrorAction SilentlyContinue |
            Where-Object { $_.LinkType -or $_.VersionInfo.ProductName -match 'Mesa' }
        foreach ($f in $files) {
            if (-not ($found | Where-Object Name -eq $f)) { Write-Host "   !! $f — нет файла" -ForegroundColor Red; $allOk = $false }
        }
        foreach ($f in $found) {
            $link = if ($f.LinkType) { " SYMLINK -> $($f.Target -join ';')" } else { '' }
            $good = ($files -contains $f.Name) -and -not $f.LinkType -and (Get-Arch $f.FullName) -eq $t.Arch
            if (-not $good) { $allOk = $false }
            $line = "   {0} {1,-22} {2,-4} {3}{4}" -f $(if ($good) { 'OK' } else { '!!' }), $f.Name, (Get-Arch $f.FullName), $f.VersionInfo.FileVersion, $link
            if ($good) { Write-Host $line -ForegroundColor Green } else { Write-Host $line -ForegroundColor Red }
        }
    }
    $env = [Environment]::GetEnvironmentVariable('GALLIUM_DRIVER', 'Machine')
    if ($env -ne 'llvmpipe') { $allOk = $false }
    Write-Host "`nGALLIUM_DRIVER (система) = $env" -ForegroundColor $(if ($env -eq 'llvmpipe') { 'Green' } else { 'Red' })
    if ($allOk) { Write-Host "`nВСЁ ОК" -ForegroundColor Green } else { Write-Host "`nЕСТЬ ПРОБЛЕМЫ — запусти 1_УСТАНОВИТЬ.cmd" -ForegroundColor Red }
}

if ($Check) { Show-State; Read-Host "`nНажми Enter, чтобы закрыть"; exit }

# --- нужны права администратора: перезапускаемся с UAC ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    exit
}

$ErrorActionPreference = 'Stop'
$log = Join-Path $root 'install.log'
Start-Transcript -Path $log -Force | Out-Null
try {
    foreach ($t in $targets) {
        if (-not (Test-Path $t.Dir)) { throw "Нет папки $($t.Dir) — сначала установи LDPlayer 14 в D:\LDPlayer\LDPlayer14" }
        foreach ($f in $files) {
            if (-not (Test-Path "$root\mesa\$($t.Arch)\$f")) { throw "Нет файла $root\mesa\$($t.Arch)\$f" }
        }
    }

    Write-Host '1) Закрываю LDPlayer...'
    Get-Process | Where-Object { $_.Path -like 'D:\LDPlayer\*' -or $_.Path -like "$box\*" } | ForEach-Object {
        Write-Host "   x $($_.Name) ($($_.Id))"; Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep 3

    Write-Host '2) Удаляю старые Mesa-файлы и симлинки (родные файлы LDPlayer не трогаются)...'
    foreach ($t in $targets) {
        Get-ChildItem $t.Dir -Filter *.dll | Where-Object { $_.LinkType -or $_.VersionInfo.ProductName -match 'Mesa' } | ForEach-Object {
            Write-Host "   - $($_.FullName)"
            [IO.File]::Delete($_.FullName)   # для симлинка удаляет только ссылку, не цель
        }
    }

    Write-Host '3) Ставлю правильные файлы...'
    foreach ($t in $targets) { foreach ($f in $files) {
        Copy-Item "$root\mesa\$($t.Arch)\$f" (Join-Path $t.Dir $f) -Force
        Write-Host "   + $($t.Arch) $f -> $($t.Dir)"
    } }

    Write-Host '4) GALLIUM_DRIVER=llvmpipe для всей системы...'
    [Environment]::SetEnvironmentVariable('GALLIUM_DRIVER', 'llvmpipe', 'Machine')

    Write-Host "`n5) Проверка:"
    Show-State
    Write-Host "`nМожно запускать LDPlayer. Лог: $log"
} catch {
    Write-Host "`nОШИБКА: $_" -ForegroundColor Red
} finally {
    Stop-Transcript | Out-Null
}
Read-Host "`nНажми Enter, чтобы закрыть"

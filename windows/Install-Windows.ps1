param([string]$PythonExe)
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot
$venvPython = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $venvPython)) {
    if ($PythonExe) {
        $basePython = $PythonExe
    } elseif (Test-Path -LiteralPath (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe')) {
        $basePython = Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe'
    } elseif (Get-Command py -ErrorAction SilentlyContinue) {
        $basePython = (& py -3.12 -c 'import sys; print(sys.executable)')
        if ($LASTEXITCODE -ne 0) { throw 'Install 64-bit Python 3.12, or pass -PythonExe.' }
    } else {
        throw 'Install 64-bit Python 3.12, or pass -PythonExe.'
    }
    & $basePython -c "import sys, struct; assert sys.version_info[:2] == (3, 12) and struct.calcsize('P') == 8, 'Require 64-bit Python 3.12'"
    if ($LASTEXITCODE -ne 0) { throw 'This build was verified on 64-bit Python 3.12.' }
    & $basePython -m venv (Join-Path $PSScriptRoot '.venv')
    if ($LASTEXITCODE -ne 0) { throw 'Failed to create .venv.' }
}
& $venvPython -m pip install --disable-pip-version-check -r (Join-Path $PSScriptRoot 'requirements-windows.txt')
if ($LASTEXITCODE -ne 0) { throw 'Failed to install dependencies.' }
$programs = Join-Path ([Environment]::GetFolderPath('Programs')) 'Littodoo'
New-Item -ItemType Directory -Path $programs -Force | Out-Null
$links = @((Join-Path ([Environment]::GetFolderPath('Desktop')) 'Littodoo.lnk'), (Join-Path $programs 'Littodoo.lnk'))
$shell = New-Object -ComObject WScript.Shell
$exe = Join-Path $PSScriptRoot 'Littodoo.exe'
foreach ($path in $links) {
    if (Test-Path -LiteralPath $path) {
        $backup = Join-Path $PSScriptRoot 'shortcut-backups'
        New-Item -ItemType Directory -Path $backup -Force | Out-Null
        Copy-Item -LiteralPath $path -Destination (Join-Path $backup ([guid]::NewGuid().ToString() + '.lnk'))
    }
    $link = $shell.CreateShortcut($path)
    $link.TargetPath = $exe
    $link.WorkingDirectory = $PSScriptRoot
    $link.IconLocation = $exe + ',0'
    $link.Description = 'Littodoo — sticky to-do'
    $link.Save()
}
& $venvPython (Join-Path $PSScriptRoot 'register_shortcuts.py') @links
if ($LASTEXITCODE -ne 0) { throw 'Failed to set AppUserModelID on shortcuts.' }
Write-Host 'Done. Double-click Desktop Littodoo. Keep this folder.'

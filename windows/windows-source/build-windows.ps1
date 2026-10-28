$ErrorActionPreference = 'Stop'
# Compile into the Windows package folder (dist/ next to this windows-source/, or app/).
$root = Split-Path -Parent $PSScriptRoot
$app = Join-Path $root 'dist'
if (-not (Test-Path -LiteralPath (Join-Path $app 'todo.py'))) { $app = Join-Path $root 'app' }
$python = Join-Path $app '.venv\Scripts\python.exe'
if (-not (Test-Path -LiteralPath $python)) { throw 'Run Install-Windows.bat in the package folder first.' }
$csc = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (-not (Test-Path -LiteralPath $csc)) { throw '64-bit .NET Framework C# compiler not found.' }
$lib = (& $python -c "from pathlib import Path; import webview; print(Path(webview.__file__).parent / 'lib')")
if ($LASTEXITCODE -ne 0) { throw 'pywebview lib folder not found.' }
$dllArgs = @('/nologo', '/target:library', '/optimize+', '/reference:System.Windows.Forms.dll', '/reference:System.Drawing.dll', ('/reference:' + (Join-Path $lib 'Microsoft.Web.WebView2.Core.dll')), ('/reference:' + (Join-Path $lib 'Microsoft.Web.WebView2.WinForms.dll')), ('/out:' + (Join-Path $app 'WindowsNative.dll')), (Join-Path $PSScriptRoot 'WindowsNative.cs'))
& $csc @dllArgs
if ($LASTEXITCODE -ne 0) { throw 'WindowsNative.dll build failed; quit the app first.' }
$exeArgs = @('/nologo', '/target:winexe', '/optimize+', '/reference:System.Windows.Forms.dll', ('/win32icon:' + (Join-Path $app 'icon.ico')), ('/out:' + (Join-Path $app 'Littodoo.exe')), (Join-Path $PSScriptRoot 'Launcher.cs'))
& $csc @exeArgs
if ($LASTEXITCODE -ne 0) { throw 'Launcher build failed; quit the app first.' }
Write-Host 'Wrote WindowsNative.dll and Littodoo.exe into' $app

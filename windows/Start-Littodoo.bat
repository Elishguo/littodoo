@echo off
chcp 65001 >nul
cd /d "%~dp0"
if exist "%~dp0.venv\Scripts\pythonw.exe" (
  start "" "%~dp0.venv\Scripts\pythonw.exe" "%~dp0launch.pyw"
) else if exist "%~dp0Littodoo.exe" (
  start "" "%~dp0Littodoo.exe"
) else (
  where py >nul 2>nul && set PY=py || set PY=python
  %PY% -m pip install --user pywebview >nul 2>nul
  start "" %PY%w "%~dp0launch.pyw" 2>nul || %PY% "%~dp0todo.py"
)

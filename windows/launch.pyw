import ctypes
import os
import runpy
import sys
import traceback
from pathlib import Path

root = Path(__file__).resolve().parent
os.chdir(root)
log_dir = Path(os.environ['LOCALAPPDATA']) / 'ToDoTie'
log_dir.mkdir(parents=True, exist_ok=True)
with (log_dir / 'startup.log').open('w', encoding='utf-8', buffering=1) as log:
    sys.stdout = log
    sys.stderr = log
    try:
        runpy.run_path(str(root / 'todo.py'), run_name='__main__')
    except Exception:
        traceback.print_exc()
        ctypes.windll.user32.MessageBoxW(
            None,
            'Littodoo failed to start. See log:\n' + str(log_dir / 'startup.log'),
            'Littodoo',
            16,
        )

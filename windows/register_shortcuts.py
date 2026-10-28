import sys
from pathlib import Path
import clr

clr.AddReference(str(Path(__file__).resolve().parent / 'WindowsNative.dll'))
from ToDoTie.Windows import ShellIdentity

for shortcut in sys.argv[1:]:
    ShellIdentity.SetShortcutIdentity(str(Path(shortcut).resolve()))

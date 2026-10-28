"""Windows-only native chrome. Imported only when os.name == 'nt'."""
import ctypes
from pathlib import Path

APP_ID = 'Littodoo.Desktop.Windows'
ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(APP_ID)


def install(window, state):
    import clr
    root = Path(__file__).resolve().parent
    clr.AddReference(str(root / 'WindowsNative.dll'))
    from ToDoTie.Windows import NativeChrome
    colors = {'white': '#FAFAFA', 'yellow': '#FFF6C8', 'mint': '#D8F3DC',
              'sky': '#D6EAF8', 'peach': '#FFE0C8', 'lilac': '#E8DFF5',
              'rose': '#F8D7DA', 'night': '#2B2B2E'}
    launcher = root / 'Littodoo.exe'
    if not launcher.exists():
        launcher = root / 'ToDo贴.exe'
    return NativeChrome.Install(window.native, str(root / 'icon.ico'),
                                str(launcher),
                                colors.get(state.get('color'), '#FAFAFA'),
                                float(state.get('opacity', 1)))

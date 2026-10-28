#!/usr/bin/env python3
"""Assemble dist/Littodoo-Windows.zip from windows/ + the shared src/ui.html."""
import os, zipfile
from pathlib import Path
root = Path(__file__).resolve().parent.parent
out = root / "dist"; out.mkdir(exist_ok=True)
zp = out / "Littodoo-Windows.zip"
with zipfile.ZipFile(zp, "w", zipfile.ZIP_DEFLATED) as z:
    for p in (root / "windows").rglob("*"):
        if p.is_file() and ".venv" not in p.parts:
            z.write(p, "Littodoo-Windows/" + p.relative_to(root / "windows").as_posix())
    z.write(root / "src" / "ui.html", "Littodoo-Windows/ui.html")
print("Wrote", zp)

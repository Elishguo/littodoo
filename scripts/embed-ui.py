#!/usr/bin/env python3
"""Embed src/ui.html into mac/main.swift (between #\"\"\" ... \"\"\"#)."""
from pathlib import Path
root = Path(__file__).resolve().parent.parent
swift = (root / "mac" / "main.swift").read_text(encoding="utf-8")
html = (root / "src" / "ui.html").read_text(encoding="utf-8").rstrip("\n")
a = swift.index('#"""\n') + 5
b = swift.index('\n"""#', a)
(root / "mac" / "main.swift").write_text(swift[:a] + html + swift[b:], encoding="utf-8")
print("Embedded src/ui.html into mac/main.swift")

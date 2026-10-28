#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Littodoo — sticky to-do for Mac / Windows"""
import json
import os
import sys
import threading
from pathlib import Path

IS_WINDOWS = os.name == "nt"
if IS_WINDOWS:
    import windows_integration

ROOT = Path(__file__).resolve().parent
UI = ROOT / "ui.html"
# Keep ToDoTie folder so existing Windows/Mac notes keep working.
if sys.platform == "darwin":
    DATA = Path.home() / "Library" / "Application Support" / "ToDoTie"
elif os.name == "nt":
    DATA = Path(os.environ.get("APPDATA", str(Path.home()))) / "ToDoTie"
else:
    DATA = Path.home() / ".config" / "ToDoTie"
DATA.mkdir(parents=True, exist_ok=True)
STATE = DATA / "state.json"

def load_state():
    if STATE.exists():
        try:
            return STATE.read_text(encoding="utf-8")
        except Exception:
            pass
    return json.dumps({"color": "white", "pin": False, "opacity": 1, "items": []}, ensure_ascii=False)

def save_state(s: str):
    STATE.write_text(s, encoding="utf-8")

HTML = UI.read_text(encoding="utf-8")
INIT = load_state()
PLATFORM = "win" if os.name == "nt" else ("mac" if sys.platform == "darwin" else "linux")
BOOT = f"<script>window.__PLATFORM__={json.dumps(PLATFORM)};window.__INIT__={INIT};</script>"
if IS_WINDOWS:
    import base64
    BOOT += "<style>" + (ROOT / "windows.css").read_text(encoding="utf-8") + "</style>"
    BOOT += "<script>window.__WINDOWS_ICON__='data:image/png;base64," + base64.b64encode((ROOT / "icon.png").read_bytes()).decode("ascii") + "';</script>"
if "</head>" in HTML:
    PAGE = HTML.replace("</head>", BOOT + "</head>", 1)
else:
    PAGE = BOOT + HTML
if IS_WINDOWS:
    PAGE = PAGE.replace("</body>", "<script>" + (ROOT / "windows.js").read_text(encoding="utf-8") + "</script></body>", 1)

try:
    import webview
except ImportError:
    print("Installing pywebview ...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "--user", "pywebview"])
    import webview

class Api:
    def __init__(self):
        self._win = None
        self._start = None
        self._chrome = None

    def msg(self, raw: str):
        try:
            b = json.loads(raw)
        except Exception:
            return
        t = b.get("type")
        w = self._win
        if t == "save":
            save_state(b.get("json") or "")
        elif t == "close":
            if IS_WINDOWS and self._chrome:
                self._chrome.Close()
            else:
                w.destroy()
        elif t == "pin":
            if IS_WINDOWS:
                if self._chrome:
                    self._chrome.SetPinned(bool(b.get("on")))
                return
            try:
                w.on_top = bool(b.get("on"))
            except Exception:
                pass
        elif t == "opacity":
            if IS_WINDOWS:
                return
            try:
                v = float(b.get("value", 1))
                w.transparent = True
                if hasattr(w, "set_window_size"):
                    pass
            except Exception:
                pass
        elif t == "drag":
            if IS_WINDOWS and self._chrome:
                self._chrome.Move()
        elif t == "appearance" and IS_WINDOWS:
            if self._chrome:
                self._chrome.SetAppearance(b.get("color", "#FAFAFA"), float(b.get("value", 1)))
        elif t == "rs":
            try:
                self._start = w.get_size()
            except Exception:
                self._start = (340, 400)
        elif t == "r":
            try:
                sw, sh = self._start or w.get_size()
                nw = max(200, int(sw + float(b.get("dx") or 0)))
                nh = max(180, int(sh + float(b.get("dy") or 0)))
                w.resize(nw, nh)
            except Exception:
                pass

api = Api()
st = json.loads(INIT)
ICON = ROOT / "icon.ico"
if not ICON.exists():
    ICON = ROOT / "icon.png"
_kw = dict(
    title="Littodoo",
    html=PAGE,
    width=340,
    height=400,
    frameless=True,
    easy_drag=True,
    on_top=bool(st.get("pin")),
    background_color="#FAFAFA",
    min_size=(200, 180),
    js_api=api,
)
if IS_WINDOWS:
    _kw.update(easy_drag=False, text_select=True, resizable=True, min_size=(220, 180))
elif ICON.exists():
    _kw["icon"] = str(ICON)
window = webview.create_window(**_kw)
api._win = window

def on_loaded():
    if IS_WINDOWS:
        window.events.shown.wait()
        api._chrome = windows_integration.install(window, st)
    try:
        window.evaluate_js("window.__native && window.__native.applyOpacity && window.__native.applyOpacity()")
    except Exception:
        pass

webview.start(func=on_loaded, debug=False, icon=str(ICON) if ICON.exists() else None)

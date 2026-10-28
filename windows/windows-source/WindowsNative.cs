using System;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;
using System.Windows.Forms;
using System.Collections.Generic;
using Microsoft.Web.WebView2.WinForms;

namespace ToDoTie.Windows {
    // Runs on the WinForms UI thread. Windows owns the entire move/resize loop.
    public sealed class NativeChrome : NativeWindow, IMessageFilter {
        readonly Form form;
        readonly string iconPath;
        int border;
        Icon appIcon;
        WebView2 browser;
        readonly HashSet<int> heldShortcutKeys = new HashSet<int>();
        public int CompletedResizes { get; private set; }

        [DllImport("user32.dll")] static extern int GetWindowLong(IntPtr hwnd, int index);
        [DllImport("user32.dll")] static extern int SetWindowLong(IntPtr hwnd, int index, int value);
        [DllImport("user32.dll")] static extern uint GetDpiForWindow(IntPtr hwnd);
        [DllImport("user32.dll")] static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int cx, int cy, uint flags);
        [DllImport("user32.dll")] static extern bool ReleaseCapture();
        [DllImport("user32.dll")] static extern short GetKeyState(int key);
        [DllImport("user32.dll")] static extern IntPtr GetAncestor(IntPtr hwnd, uint flags);
        [DllImport("user32.dll")] static extern IntPtr SendMessage(IntPtr hwnd, int msg, IntPtr wp, IntPtr lp);
        [DllImport("dwmapi.dll")] static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int value, int size);

        public static NativeChrome Install(Form form, string iconPath, string launcher, string color, double opacity) {
            NativeChrome chrome = null;
            form.Invoke(new Action(delegate { chrome = new NativeChrome(form, iconPath, launcher, color, opacity); }));
            return chrome;
        }

        NativeChrome(Form form, string iconPath, string launcher, string color, double opacity) {
            this.form = form;
            this.iconPath = iconPath;
            AssignHandle(form.Handle);
            // Keep a real resizable system frame, while drawing our own client area.
            int style = GetWindowLong(Handle, -16);
            SetWindowLong(Handle, -16, style | 0x00040000 | 0x00020000 | 0x00010000 | 0x00080000);
            UpdateDpi();
            appIcon = new Icon(iconPath);
            form.Icon = appIcon;
            form.ShowIcon = true;
            ShellIdentity.SetWindowIdentity(Handle, launcher);
            SetAppearanceCore(color, opacity);
            int corner = 2;
            DwmSetWindowAttribute(Handle, 33, ref corner, 4);
            SetWindowPos(Handle, IntPtr.Zero, 0, 0, 0, 0, 0x0020 | 0x0001 | 0x0002 | 0x0004 | 0x0010);
            foreach (Control control in form.Controls) {
                browser = control as WebView2;
                if (browser != null) break;
            }
            if (browser != null) {
                browser.KeyDown += ShortcutKeyDown;
                browser.KeyUp += ShortcutKeyUp;
            }
            Application.AddMessageFilter(this);
            form.Deactivate += delegate { heldShortcutKeys.Clear(); };
            form.FormClosed += delegate {
                Application.RemoveMessageFilter(this);
                if (browser != null) {
                    browser.KeyDown -= ShortcutKeyDown;
                    browser.KeyUp -= ShortcutKeyUp;
                }
                ReleaseHandle(); appIcon.Dispose();
            };
        }

        static string ShortcutAction(int key) {
            switch (key) {
                case 0xBB: case 0x6B: return "opacity-up"; // =/+ and numpad +
                case 0xBD: case 0x6D: return "opacity-down"; // - and numpad -
                case 0x46: return "pin";
                case 0x4E: return "add";
                default: return null;
            }
        }

        void QueueShortcut(string action, int key, bool repeat) {
            bool wasHeld = heldShortcutKeys.Contains(key);
            heldShortcutKeys.Add(key);
            if ((repeat || wasHeld) && (action == "pin" || action == "add")) return;
            // Defer browser calls until the synchronous key event has returned.
            form.BeginInvoke(new Action(delegate {
                if (browser != null && !browser.IsDisposed && browser.CoreWebView2 != null)
                    browser.ExecuteScriptAsync("window.__windowsShortcut && window.__windowsShortcut('" + action + "')");
            }));
        }

        void ShortcutKeyDown(object sender, KeyEventArgs e) {
            string action = ShortcutAction(e.KeyValue);
            if (action == null || !e.Alt || e.Control) return;
            e.Handled = true;
            e.SuppressKeyPress = true;
            QueueShortcut(action, e.KeyValue, false);
        }

        void ShortcutKeyUp(object sender, KeyEventArgs e) {
            if (!heldShortcutKeys.Remove(e.KeyValue)) return;
            e.Handled = true;
            e.SuppressKeyPress = true;
        }

        public bool PreFilterMessage(ref Message m) {
            bool down = m.Msg == 0x0100 || m.Msg == 0x0104;
            bool up = m.Msg == 0x0101 || m.Msg == 0x0105;
            if ((!down && !up) || GetAncestor(m.HWnd, 2) != Handle) return false;
            int key = m.WParam.ToInt32();
            string action = ShortcutAction(key);
            if (action == null) return false;
            if (up) return heldShortcutKeys.Remove(key);
            bool alt = (m.LParam.ToInt64() & (1L << 29)) != 0 || GetKeyState(0x12) < 0;
            if (!alt || GetKeyState(0x11) < 0) return false;
            QueueShortcut(action, key, (m.LParam.ToInt64() & (1L << 30)) != 0);
            return true;
        }

        void UpdateDpi() {
            border = Math.Max(5, (int)Math.Round(6 * GetDpiForWindow(Handle) / 96.0));
            // Expose the native frame around WebView2, so child HWNDs cannot swallow it.
            form.Padding = new Padding(border);
        }

        public void Move() {
            form.BeginInvoke(new Action(delegate {
                ReleaseCapture();
                SendMessage(Handle, 0x00A1, new IntPtr(2), IntPtr.Zero);
            }));
        }

        public void SetPinned(bool on) {
            form.BeginInvoke(new Action(delegate { form.TopMost = on; }));
        }

        public void Close() {
            form.BeginInvoke(new Action(delegate { form.Close(); }));
        }

        public void SetAppearance(string color, double opacity) {
            if (form.IsDisposed) return;
            form.BeginInvoke(new Action(delegate { SetAppearanceCore(color, opacity); }));
        }

        void SetAppearanceCore(string color, double opacity) {
            Color c = ColorTranslator.FromHtml(color);
            form.BackColor = c;
            form.Opacity = Math.Min(1, Math.Max(0.25, opacity));
            int borderColor = c.R | c.G << 8 | c.B << 16;
            DwmSetWindowAttribute(Handle, 34, ref borderColor, 4);
        }

        protected override void WndProc(ref Message m) {
            if (m.Msg == 0x0083) { // WM_NCCALCSIZE: no system title bar
                m.Result = IntPtr.Zero;
                return;
            }
            if (m.Msg == 0x0084 && form.WindowState == FormWindowState.Normal) {
                long packed = m.LParam.ToInt64();
                Point p = form.PointToClient(new Point((short)(packed & 0xffff), (short)((packed >> 16) & 0xffff)));
                int corner = Math.Max(border, border * 2);
                bool left = p.X < border, right = p.X >= form.ClientSize.Width - border;
                bool top = p.Y < border, bottom = p.Y >= form.ClientSize.Height - border;
                int hit = 1;
                if (top) hit = p.X < corner ? 13 : p.X >= form.ClientSize.Width - corner ? 14 : 12;
                else if (bottom) hit = p.X < corner ? 16 : p.X >= form.ClientSize.Width - corner ? 17 : 15;
                else if (left) hit = p.Y < corner ? 13 : p.Y >= form.ClientSize.Height - corner ? 16 : 10;
                else if (right) hit = p.Y < corner ? 14 : p.Y >= form.ClientSize.Height - corner ? 17 : 11;
                m.Result = new IntPtr(hit);
                return;
            }
            if (m.Msg == 0x02E0) { // WM_DPICHANGED
                base.WndProc(ref m);
                UpdateDpi();
                return;
            }
            if (m.Msg == 0x0232) CompletedResizes++; // WM_EXITSIZEMOVE
            base.WndProc(ref m);
        }
    }

    public static class ShellIdentity {
        public const string AppId = "Littodoo.Desktop.Windows";
        static readonly Guid PropertySet = new Guid("9F4C2855-9F79-4B39-A8D0-E1D42DE1D5F3");
        [DllImport("shell32.dll", CharSet = CharSet.Unicode)] public static extern int SetCurrentProcessExplicitAppUserModelID(string id);
        [DllImport("shell32.dll")] static extern int SHGetPropertyStoreForWindow(IntPtr hwnd, ref Guid iid, [MarshalAs(UnmanagedType.Interface)] out IPropertyStore store);
        [StructLayout(LayoutKind.Sequential)] struct PropertyKey {
            public Guid format;
            public uint id;
            public PropertyKey(uint id) { format = PropertySet; this.id = id; }
        }
        [StructLayout(LayoutKind.Sequential)] struct PropVariant {
            public ushort type, r1, r2, r3;
            public IntPtr value, extra;
        }
        [ComImport, Guid("886D8EEB-8CF2-4446-8D02-CDBA1DBDCF99"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
        interface IPropertyStore {
            void GetCount(out uint count);
            void GetAt(uint index, out PropertyKey key);
            void GetValue(ref PropertyKey key, out PropVariant value);
            void SetValue(ref PropertyKey key, ref PropVariant value);
            void Commit();
        }
        static void SetString(IPropertyStore store, uint id, string text) {
            PropertyKey key = new PropertyKey(id);
            PropVariant value = new PropVariant { type = 31, value = Marshal.StringToCoTaskMemUni(text) };
            try { store.SetValue(ref key, ref value); }
            finally { Marshal.FreeCoTaskMem(value.value); }
        }
        public static void SetWindowIdentity(IntPtr hwnd, string launcher) {
            Guid iid = typeof(IPropertyStore).GUID;
            IPropertyStore store;
            Marshal.ThrowExceptionForHR(SHGetPropertyStoreForWindow(hwnd, ref iid, out store));
            try {
                SetString(store, 5, AppId);
                SetString(store, 2, "\"" + launcher + "\"");
                SetString(store, 3, launcher + ",0");
                SetString(store, 4, "Littodoo");
                store.Commit();
            } finally { Marshal.ReleaseComObject(store); }
        }
        public static void SetShortcutIdentity(string path) {
            object link = Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("00021401-0000-0000-C000-000000000046")));
            try {
                IPersistFile file = (IPersistFile)link;
                file.Load(path, 2);
                IPropertyStore store = (IPropertyStore)link;
                SetString(store, 5, AppId);
                store.Commit();
                file.Save(path, true);
            } finally { Marshal.ReleaseComObject(link); }
        }
    }
}

using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;
using System.Reflection;
[assembly: AssemblyTitle("Littodoo")]
[assembly: AssemblyProduct("Littodoo")]
[assembly: AssemblyDescription("sticky to-do for Windows")]
[assembly: AssemblyVersion("1.1.0.0")]
static class Launcher {
    [STAThread] static void Main() {
        string root = AppDomain.CurrentDomain.BaseDirectory;
        try {
            Process.Start(new ProcessStartInfo {
                FileName = Path.Combine(root, ".venv", "Scripts", "pythonw.exe"),
                Arguments = "\"" + Path.Combine(root, "launch.pyw") + "\"",
                WorkingDirectory = root,
                UseShellExecute = false,
                CreateNoWindow = true
            });
        } catch (Exception e) { MessageBox.Show(e.Message, "Littodoo启动失败"); }
    }
}

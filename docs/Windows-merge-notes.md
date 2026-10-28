# ToDo贴 Windows 优化合并包

本包包含本次在 Windows 上实际部署的优化代码、编译好的 Windows 文件和合并说明，供 Mac 端项目维护者组装。它不是 Mac 的 .app 安装包，也不是无需 Python 的独立 Windows 安装程序。

## 包含的优化

- Windows 桌面、开始菜单及任务栏图标：带图标的启动器、独立 AppUserModelID、快捷方式和窗口重启属性。
- 四边、四角的原生窗口缩放及标题区域移动；工具栏随窗口宽度靠右排列。
- Alt + 加号/减号调节真实窗口透明度，每次 8%，范围 25%–100%；支持 =/+ 与小键盘加减。
- Alt + F 切换原生置顶；按住不反复切换。Alt + N 添加待办。
- 首次没有待办时，点击正文空白处即可出现输入框并聚焦。
- 关闭前等待待办保存；按钮悬停、置顶提示、窄窗口布局和 Windows 原生透明度。

## Mac 端怎么合并

1. 保留你们现有的 Mac .app、Mac 专用入口和资源，以及其构建流程。
2. 将 app/windows.js、windows.css、windows_integration.py、WindowsNative.dll、ToDo贴.exe、launch.pyw、icon.ico、icon.png 和 Windows 安装/启动相关文件加入项目的 Windows 发行目录，保持这些文件与 todo.py 位于同一层。
3. app/todo.py 是当前可用的整合入口。若你们的 todo.py 还是最初提供的版本，可比较后采用此文件；若 Mac 端已有后续修改，请按 docs/todo-original-to-windows.patch 合并 Windows 分支，不要覆盖 Mac 新增逻辑。
4. app/ui.html 与最初提供的文件完全一致，仅作为组装和对照文件。若 Mac 端已修改 ui.html，保留 Mac 端版本，再核对下面的 DOM/脚本接口。
5. Windows 资源仅在 os.name == "nt" 时导入/注入。不要把 Windows 样式、事件处理或原生 DLL 导入移到公共/Mac 分支。
6. windows-source/ 放的是 DLL 与带图标启动器的 C# 源码。Mac 可以管理这些源码和复制现成二进制；本包重编译脚本只在 Windows 上运行。无需在 Mac 端重新编译 Windows 文件。

共享页面依赖的接口：head、note、list、bColor、bPin、bAdd、bClose、grip 等 DOM id；S、pending、post、setPin、color、render、addAtCaret 以及 window.__native。如果 Mac 端变更这些名字，需要同步调整 Windows 插件。

## Windows 上安装和测试

已验证环境：Windows 64 位、Python 3.12.10、.NET Framework 4.8、Edge WebView2、pywebview 6.2.1。依赖版本记录在 app/requirements-windows.txt。

将包解压到固定目录，进入 app 文件夹，运行「安装-Windows.bat」。首次会在此目录生成 Windows 的 .venv 并下载依赖，然后创建带应用标识的桌面和开始菜单快捷方式。已有待办保存在用户的 %APPDATA%/ToDoTie/state.json，不在本包内。

若 Python 安装在自定义位置，可用 Windows PowerShell 执行：

```powershell
.\安装-Windows.ps1 -PythonExe "D:\Python312\python.exe"
```

安装完成后使用桌面快捷方式，或运行 app/ToDo贴.exe、启动-Windows.bat。ToDo贴.exe 是带图标的启动器，会调用同目录 .venv/Scripts/pythonw.exe；不要单独只发送这个 exe。

如修改 C#，先退出应用，再在 Windows PowerShell 中运行 windows-source/build-windows.ps1。编译结果会写回 app/WindowsNative.dll 和 app/ToDo贴.exe。

## 文件与边界

- app/：可组装的应用文件、Windows 二进制、依赖清单、安装和启动脚本。
- windows-source/：原生窗口及快捷键代码、启动器代码、Windows 编译脚本。
- docs/：相对最初 todo.py 的差异、已完成的验证记录。
- SHA256SUMS.txt：包内文件完整性校验。

本包不含个人待办、日志、旧版备份、电脑专属绝对路径或本机 .venv。Mac 界面设计没有改动；本轮没有在 Mac 真机编译或运行测试。新附带的 Windows 安装脚本已做语法检查，未在另一台全新电脑进行安装验证。

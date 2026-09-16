# Neuromedia LDPlayer 软件渲染

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **状态：仅源代码工具包。** 公开仓库包含脚本和文档，不包含任何第三方 Mesa DLL。

## 项目用途

Neuromedia LDPlayer Software Rendering 用于在没有合适独立显卡、或通过 RDP 连接的 Windows 服务器上，为 LDPlayer 14 准备软件渲染环境。此类环境中，Android 模拟器有时无法获得可用的 OpenGL 图形上下文，表现为启动后卡住、黑屏或直接退出。本项目的做法并不是向整个 Windows 安装一套图形驱动，而是将经你自行审核的 Mesa/llvmpipe 文件放到 **LDPlayer 自身的目录** 中，再由启动进程加载它们。

它不是 Android 模拟器，不是 LDPlayer 的修改版或破解包，也不保证所有游戏和应用可用。它由公开的 CMD、PowerShell 脚本和操作说明组成，用来完成可复核的部署：确认安装目录、区分 x86 与 x64 DLL、复制三个指定文件，并设置 `GALLIUM_DRIVER=llvmpipe`。llvmpipe 主要使用 CPU 绘制图形；它可以让没有可用 GPU 的场景获得启动机会，但性能、耗电、兼容性和多开能力通常明显低于正常 GPU 渲染。

## 脚本实际会做什么

双击 `1_INSTALL.cmd` 会以管理员身份调用 `install.ps1`。在当前实现中，它会：

1. 检查 LDPlayer 目标目录以及 `mesa/x86`、`mesa/x64` 中所需文件是否存在；
2. 结束路径位于 LDPlayer 相关目录中的进程；
3. 只删除被识别为 Mesa 的 DLL 或符号链接，不应删除普通 LDPlayer DLL；
4. 将 `opengl32.dll`、`libgallium_wgl.dll`、`libglapi.dll` 分别复制到正确架构的目录；
5. 在**机器级**环境变量中写入 `GALLIUM_DRIVER=llvmpipe`；
6. 输出文件存在性、PE 架构和环境变量的诊断结果，并把安装记录写入 `install.log`。

`2_CHECK.cmd` 仅以 `-Check` 模式运行，不写入文件、不停止进程，也不修改环境变量。每次更新、修复或重装 LDPlayer 后都应先运行它，因为更新可能移除、替换或覆盖此前放入的 DLL。脚本的“OK”只表示它找到了预期文件并识别出架构；并不等同于某个 Android 映像、游戏或业务程序已经得到厂商支持。

## 安装前的要求与检查

脚本当前的默认路径写在 `install.ps1` 中：

```text
D:\LDPlayer\LDPlayer14\              # dnplayer.exe，使用 x86 Mesa DLL
C:\Program Files\ldplayer9box\       # Ld9BoxHeadless.exe，使用 x64 Mesa DLL
```

如果你的 LDPlayer 位于别处，先用文本编辑器打开 `install.ps1`，修改 `$ld` 和 `$box`，保存后再运行。不要只因目录名称相似就猜测路径；请确认其中确实有对应的可执行文件。也绝不能把 x64 DLL 复制给 x86 进程，或反过来复制。Windows 往往只会显示含糊的加载失败，而架构错误本身足以导致启动失败。

操作前请关闭所有 LDPlayer 实例及可能访问这些文件的维护工具，安排维护窗口，并备份两个目标目录中现有的相关文件和目录清单。若服务器由组织或云服务商管理，还应先确认其远程访问、软件安装、许可、变更管理和安全策略允许此操作。机器级环境变量通常需要注销再登录 RDP，或重启后，新的进程才会可靠读取到新值；已经打开的终端和模拟器不会自动继承修改后的环境。

## 获取 Mesa DLL：来源、许可与校验

本公开仓库故意不提供 Mesa 二进制文件。曾随私有工具包出现的 DLL 没有随附完整许可证文本、官方发布地址或可验证的来源链，因此不适合在公开仓库重新分发。这一限制不是让用户绕过许可，而是要求部署者自行取得可合法使用、来源明确且与 Windows/目标架构兼容的构建。

请从有清楚发布条款的来源取得 Windows Mesa 构建，保留其许可证、notice、下载地址、版本和校验值。根据 [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md) 的目录规则放置文件：每个 `mesa/x86/` 和 `mesa/x64/` 目录都必须包含上述三个 DLL。使用供应方提供的 SHA-256 或其他可信校验值核对下载文件；仓库中的 `assets/mesa-binaries.example.sha256` 只是格式示例，并不是任意文件的授权或真实性证明。Mesa 的许可资料可见 <https://docs.mesa3d.org/license.html>，但这不意味着网络上任一打包 DLL 都可以不经核查地传播。

## 推荐的部署流程

1. 阅读 `THIRD_PARTY_BINARIES.md`、本说明和 `SECURITY.md`，记录当前 LDPlayer 版本与目录。
2. 备份目标目录，收集合法获得的 DLL、许可证和校验记录；确认每个文件的架构。
3. 在计划维护窗口关闭模拟器，运行 `2_CHECK.cmd` 保存安装前结果。
4. 以可信管理员帐户运行 `1_INSTALL.cmd`，接受 UAC 提示；审阅控制台输出和仓库根目录的 `install.log`。
5. 注销/登录 RDP 或重启，然后再次运行 `2_CHECK.cmd`。确认两个目录均显示正确的 x86/x64 文件，且机器级变量为 `llvmpipe`。
6. 先以一个非关键实例测试启动、日志和应用行为，再决定是否扩大使用范围。监控 CPU、内存、会话响应和应用错误，而不是把“能启动”误解为高性能配置。

不要在运行中的实例上覆盖 DLL，不要用来历不明的批处理替换系统图形组件，也不要将本项目用于规避软件授权、访问控制、反作弊、企业策略或云服务商限制。

## 回滚与故障排查

若需要撤销，先完全退出 LDPlayer。仅从这两个目标目录删除由本流程安装的 `opengl32.dll`、`libgallium_wgl.dll`、`libglapi.dll`，然后删除机器级 `GALLIUM_DRIVER` 环境变量，并恢复你的备份。若你不确定某个 DLL 是否属于 Mesa，**不要猜测并删除它**：先复制保存、检查文件属性和来源。`install.ps1` 的注释也说明了脚本识别和清理的范围。

常见问题包括：目标目录不存在（路径与实际安装不符）；源 DLL 缺失（目录结构不完整）；检查报告架构不符（x86/x64 放错）；变量未生效（重新登录或重启）；更新后失效（更新覆盖文件，重新审核后再部署）。若安装脚本报错，请保留 `install.log`、LDPlayer 版本、已脱敏的路径和校验信息再分析；不要把 RDP 密码、私有 IP、客户数据或未经验证的二进制文件发到公开渠道。

## 责任边界与协作

本仓库中的 Neuromedia 脚本和文档采用 [MIT License](../LICENSE)。LDPlayer、Mesa 及任何 DLL 均是第三方组件，各自适用自己的许可和支持政策。本项目与 LDPlayer 或 Mesa 没有关联，也不表示它们认可或支持这一部署方法。欢迎讨论合规的 Windows 环境自动化、可复现文档、安全脚本集成和已记录安装路径的适配： [Telegram](https://t.me/TheBotsLab) 或 `BotsLab@proton.me`。

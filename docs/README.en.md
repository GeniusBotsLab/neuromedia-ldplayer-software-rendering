# Neuromedia LDPlayer Software Rendering

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **Status: source-only toolkit.** This public repository contains scripts and documentation, not third-party Mesa DLL files.

## Purpose

Neuromedia LDPlayer Software Rendering is a small Windows preparation toolkit for running LDPlayer 14 where a suitable GPU is unavailable, inaccessible, or unsuitable for a remote desktop session. Typical examples include a server reached through RDP, a virtual machine without GPU passthrough, or a host where the graphics driver does not expose the OpenGL path required by the emulator. In those situations LDPlayer can fail during launch, freeze on a blank window, or stop before the Android instance is ready.

The project’s approach is deliberately narrow: use Mesa/llvmpipe software rendering **inside LDPlayer’s own folders** rather than replacing the operating system graphics stack. Mesa’s llvmpipe driver renders on the CPU. It can make a startup path available when hardware acceleration is not, but it is not a promise of gaming performance, low latency, compatibility with every Android image, or support for every application. Treat it as a controlled fallback and test the actual workload.

This repository is neither an Android emulator nor a repackaged or modified copy of LDPlayer. It provides readable PowerShell/CMD automation and operational guidance for placing user-supplied, verified Mesa DLLs into the appropriate locations, checking their architecture, and setting `GALLIUM_DRIVER=llvmpipe` at system scope.

## What the scripts do

`1_INSTALL.cmd` starts `install.ps1` with an elevation request. The installer checks that the expected LDPlayer directories exist, stops LDPlayer-related processes, removes only Mesa files or links it detects, copies prepared x86 and x64 DLLs to their intended destinations, sets the system environment variable, and prints diagnostic output. It changes running software and files in application directories, so schedule a maintenance window and make backups before its first use on a production host.

`2_CHECK.cmd` is the non-destructive validation entry point. It reports whether the expected files are present, whether their architectures match the targets, and whether the system variable is configured. Run it after installation, after an LDPlayer update, and whenever startup behavior changes. Updates and repairs may replace application files, so a previously working configuration can require reinstallation.

## Requirements and preparation

The default paths in `install.ps1` target LDPlayer 14:

```text
D:\LDPlayer\LDPlayer14\              # x86 DLLs for dnplayer.exe
C:\Program Files\ldplayer9box\       # x64 DLLs for Ld9BoxHeadless.exe
```

If your installation uses different directories, edit `$ld` and `$box` in `install.ps1` before executing anything. Confirm the executable names and folders on the target machine rather than copying assumptions from another server. Do not interchange the two architectures: a 32-bit process needs 32-bit DLLs and a 64-bit process needs 64-bit DLLs. A wrong DLL can prevent the process from launching.

Close LDPlayer and related tools first, and notify any users who share the host. Because the installer may stop processes, do not run it during an active automation job. A new RDP sign-in or a reboot is normally required before all new processes inherit a changed machine-level environment variable. Save a copy of the original target directories and record the DLL source, version, hashes, and date of installation.

## Mesa binaries, provenance, and licensing

Third-party Mesa binaries are intentionally absent from this public repository. The original private bundle contained DLLs without an included license file, an official distribution link, or a verifiable provenance chain. Publishing opaque binaries under unknown redistribution terms would be inappropriate.

Obtain compatible Windows Mesa builds from a source whose distribution terms are clear. Preserve its license and notice files, verify published checksums where available, scan the downloaded archive according to your organization’s policy, and place the required three DLLs for each architecture in `mesa/x86/` and `mesa/x64/`. Read [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md) before populating those directories. Mesa licensing information is available at <https://docs.mesa3d.org/license.html>; that page does not by itself authorize redistribution of every archive found online.

## Validation, troubleshooting, and rollback

Start with `2_CHECK.cmd`, then launch LDPlayer only after the reported paths and architectures look correct. If it still fails, collect the checker output, the exact LDPlayer version, Windows version, launch method, and relevant application logs. Check that no older `opengl32.dll`, `libgallium_wgl.dll`, or `libglapi.dll` remains in the wrong target directory. Do not disable endpoint protection or Windows security controls merely to test this configuration; investigate the source and signature of files instead.

To roll back, close LDPlayer, remove the installed Mesa files from both target directories, and remove the system `GALLIUM_DRIVER` variable. The comments in `install.ps1` document the manual procedure. Restore your backup if an original file existed. If you cannot confidently identify a file as an installed Mesa component, do not delete it: preserve a copy and establish its origin first.

## Safe operation and scope

Use only on systems you administer and only with software and binaries you are permitted to install. This toolkit must not be used to bypass licenses, access controls, provider restrictions, corporate policy, or game/application protections. Restrict RDP and emulator-directory access, avoid sending credentials or private host data in support channels, and keep deployment records for repeatability.

Neuromedia scripts and documentation are available under the [MIT License](../LICENSE). LDPlayer and Mesa are third-party products subject to their own terms. This project is not affiliated with, endorsed by, or supported by LDPlayer or Mesa. For permitted collaboration on Windows automation, reproducible deployment instructions, or documented installation paths, contact [Telegram](https://t.me/TheBotsLab) or `BotsLab@proton.me`.

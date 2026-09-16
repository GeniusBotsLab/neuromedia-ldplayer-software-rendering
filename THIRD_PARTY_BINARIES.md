# Included verified Mesa binaries

This repository includes the six Mesa 21.3.1 Windows DLL files required by `install.ps1`. They were verified byte-for-byte against the official `pal1000/mesa-dist-win` GitHub release asset `mesa3d-21.3.1-release-msvc.7z`.

The exact provenance, asset hash, individual file hashes, original upstream README, and the `pal1000/mesa-dist-win` MIT license are preserved under [`third_party/pal1000-mesa-dist-win/`](third_party/pal1000-mesa-dist-win/).

```text
mesa/x86/opengl32.dll
mesa/x86/libgallium_wgl.dll
mesa/x86/libglapi.dll
mesa/x64/opengl32.dll
mesa/x64/libgallium_wgl.dll
mesa/x64/libglapi.dll
```

Do not replace these files with arbitrary DLLs. If an update is needed, record the official upstream source, asset hash, per-file hashes and applicable notices before publishing it.

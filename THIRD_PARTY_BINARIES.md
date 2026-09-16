# Third-party Mesa binaries: distribution boundary

The original private bundle contained six Windows DLL files reporting `Mesa 21.3.1` / `llvmpipe`: three x86 and three x64 files. They are **intentionally not committed** to this public repository.

The supplied bundle did not contain a licence notice, an official distributor URL, or a reproducible build record for those exact binaries. A public repository must not redistribute opaque third-party binaries without documented provenance and applicable licence notices.

To use this installer, obtain compatible Mesa Windows binaries from a source that provides the required licence and attribution information, verify their hashes, then place these files in the following layout:

```text
mesa/x86/opengl32.dll
mesa/x86/libgallium_wgl.dll
mesa/x86/libglapi.dll
mesa/x64/opengl32.dll
mesa/x64/libgallium_wgl.dll
mesa/x64/libglapi.dll
```

Mesa itself is an open-source project with its own licensing documentation: <https://docs.mesa3d.org/license.html>. This link does not identify the provenance of any particular prebuilt Windows DLL.

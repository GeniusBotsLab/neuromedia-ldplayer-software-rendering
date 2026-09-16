# Mesa binary provenance

The six DLL files in `../../mesa/x86/` and `../../mesa/x64/` are byte-for-byte verified copies of the corresponding files from the official **pal1000/mesa-dist-win** GitHub release:

- Project: <https://github.com/pal1000/mesa-dist-win>
- Release tag: `21.3.1`
- Asset: `mesa3d-21.3.1-release-msvc.7z`
- Asset URL: <https://github.com/pal1000/mesa-dist-win/releases/download/21.3.1/mesa3d-21.3.1-release-msvc.7z>
- Downloaded asset SHA-256: `c086983694f9be06462f0d982392c65f13433558b47bc05468521f12a144d775`

The source bundle received over private SFTP was compared against this official release. SHA-256 matched for all six distributed DLLs. Individual DLL hashes are recorded in `SHA256SUMS`.

## Licence and attribution

`pal1000/mesa-dist-win` publishes its own wrapper/distribution repository under the MIT License; its upstream LICENSE text is retained in this directory. Mesa itself includes multiple components under their respective upstream licence notices. The official release asset should be consulted for any additional notices relevant to the distributed binaries.

This Neuromedia repository preserves the pal1000 attribution and does not claim authorship of Mesa or its Windows distribution. Mesa and LDPlayer remain independent third-party products; their authors do not endorse this repository.

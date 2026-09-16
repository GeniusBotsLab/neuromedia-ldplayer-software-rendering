@echo off
rem Install Mesa for LDPlayer 14: closes LDPlayer, removes old Mesa files, installs correct ones (asks for admin).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

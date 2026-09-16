@echo off
rem Check only: shows what Mesa files are installed. Changes nothing, no admin needed.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1" -Check

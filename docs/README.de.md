# Neuromedia LDPlayer Software Rendering

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **Status: Toolkit nur mit Quelltexten.** Dieses öffentliche Repository enthält Skripte und Dokumentation, jedoch keine Mesa-DLLs von Dritten.

## Zweck

Neuromedia LDPlayer Software Rendering ist ein kleines Werkzeugpaket zur Vorbereitung von Windows für LDPlayer 14, wenn keine passende GPU verfügbar, zugänglich oder für eine Remotedesktopsitzung geeignet ist. Das kann einen per RDP erreichbaren Server, eine virtuelle Maschine ohne GPU-Passthrough oder einen Host betreffen, dessen Grafiktreiber den vom Emulator benötigten OpenGL-Pfad nicht bereitstellt. Unter diesen Bedingungen kann LDPlayer beim Start abbrechen, in einem leeren Fenster hängen bleiben oder die Android-Instanz nicht bis zur Bereitschaft starten.

Der Ansatz des Projekts ist bewusst eng gefasst: Mesa/llvmpipe-Software-Rendering wird **innerhalb der LDPlayer-Ordner** eingesetzt, statt den Grafik-Stack von ganz Windows zu ersetzen. Der llvmpipe-Treiber rendert auf der CPU. Er kann einen Start ermöglichen, wenn Hardwarebeschleunigung fehlt, verspricht aber weder Spieleleistung noch geringe Latenz oder Kompatibilität mit jedem Android-Image und jeder App. Verwenden Sie ihn als kontrollierte Ausweichlösung und testen Sie die reale Arbeitslast.

Dieses Repository ist weder ein Android-Emulator noch eine neu verpackte oder modifizierte LDPlayer-Version. Es enthält lesbare PowerShell-/CMD-Automatisierung und Hinweise, um vom Benutzer bereitgestellte und geprüfte Mesa-DLLs an den richtigen Ort zu kopieren, deren Architektur zu prüfen und `GALLIUM_DRIVER=llvmpipe` als Systemvariable zu setzen.

## Aufgaben der Skripte

`1_INSTALL.cmd` startet `install.ps1` mit einer Anforderung zur Rechteerhöhung. Das Installationsskript prüft die erwarteten LDPlayer-Verzeichnisse, beendet zugehörige Prozesse, entfernt nur erkannte Mesa-Dateien oder Links, kopiert vorbereitete x86- und x64-DLLs an die vorgesehenen Ziele, setzt die Systemvariable und zeigt Diagnosen an. Da es Programmdateien und laufende Prozesse verändert, sollten Sie auf einem Produktivserver zuerst ein Wartungsfenster planen und Sicherungen erstellen.

`2_CHECK.cmd` ist der zerstörungsfreie Prüfaufruf. Es meldet, ob die erwarteten Dateien vorhanden sind, ob ihre Architektur zu den Zielprozessen passt und ob die Systemvariable konfiguriert ist. Führen Sie es nach der Installation, nach einem LDPlayer-Update und bei verändertem Startverhalten aus. Updates oder Reparaturen können Programmdateien ersetzen; eine zuvor funktionierende Konfiguration muss dann möglicherweise erneut installiert werden.

## Voraussetzungen und Vorbereitung

Die Standardpfade in `install.ps1` gelten für LDPlayer 14:

```text
D:\LDPlayer\LDPlayer14\              # x86-DLLs für dnplayer.exe
C:\Program Files\ldplayer9box\       # x64-DLLs für Ld9BoxHeadless.exe
```

Bei abweichender Installation bearbeiten Sie vor jeder Ausführung `$ld` und `$box` in `install.ps1`. Prüfen Sie Programmnamen und Ordner direkt auf dem Zielsystem, statt Annahmen von einem anderen Server zu übernehmen. Vertauschen Sie die Architekturen niemals: Ein 32-Bit-Prozess benötigt 32-Bit-DLLs, ein 64-Bit-Prozess 64-Bit-DLLs. Eine falsche DLL kann den Programmstart vollständig verhindern.

Beenden Sie LDPlayer und zugehörige Werkzeuge und informieren Sie Nutzer eines gemeinsam verwendeten Hosts. Weil das Installationsskript Prozesse beenden kann, darf es nicht während eines laufenden Automatisierungsjobs ausgeführt werden. Nach einer Änderung der systemweiten Umgebungsvariable sind meist eine neue RDP-Anmeldung oder ein Neustart nötig, damit alle neuen Prozesse den Wert erhalten. Sichern Sie die ursprünglichen Zielordner und dokumentieren Sie Quelle, Version, Prüfsummen und Installationsdatum der DLLs.

## Mesa-Binärdateien, Herkunft und Lizenzen

Mesa-Binärdateien von Dritten sind absichtlich nicht im öffentlichen Repository enthalten. Das ursprüngliche private Paket enthielt DLLs ohne beigefügte Lizenzdatei, offiziellen Distributionslink oder überprüfbare Herkunftskette. Undurchsichtige Binärdateien mit unklaren Weitergabebedingungen zu veröffentlichen wäre nicht vertretbar.

Beziehen Sie kompatible Mesa-Builds für Windows nur aus einer Quelle mit eindeutigen Verteilungsbedingungen. Bewahren Sie Lizenz- und Hinweisdateien auf, kontrollieren Sie veröffentlichte Prüfsummen, sofern vorhanden, prüfen Sie das Archiv nach den Regeln Ihrer Organisation und legen Sie die jeweils drei erforderlichen DLLs in `mesa/x86/` sowie `mesa/x64/` ab. Lesen Sie vorab [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md). Informationen zur Mesa-Lizenz stehen unter <https://docs.mesa3d.org/license.html>; diese Seite erlaubt nicht automatisch die Weitergabe jedes beliebigen Archivs aus dem Internet.

## Prüfung, Fehlersuche und Rückbau

Beginnen Sie mit `2_CHECK.cmd` und starten Sie LDPlayer erst, wenn Pfade und Architekturen im Bericht plausibel sind. Besteht das Problem weiter, sichern Sie die Prüfausgabe, die genaue LDPlayer-Version, Windows-Version, Startmethode und relevante Anwendungsprotokolle. Kontrollieren Sie, dass keine ältere `opengl32.dll`, `libgallium_wgl.dll` oder `libglapi.dll` im falschen Zielordner verblieben ist. Deaktivieren Sie Endpoint-Schutz oder Windows-Sicherheitsfunktionen nicht nur für einen Test; untersuchen Sie stattdessen Herkunft und Signatur der Dateien.

Zum Rückbau schließen Sie LDPlayer, entfernen die installierten Mesa-Dateien aus beiden Zielordnern und löschen die Systemvariable `GALLIUM_DRIVER`. Die Kommentare in `install.ps1` beschreiben die manuellen Schritte. Gab es eine Originaldatei, stellen Sie sie aus der Sicherung wieder her. Wenn Sie eine Datei nicht sicher als installierte Mesa-Komponente erkennen, löschen Sie sie nicht: bewahren Sie eine Kopie auf und klären Sie zuerst ihre Herkunft.

## Sicherer Betrieb und Grenzen

Setzen Sie dieses Paket nur auf Systemen ein, die Sie verwalten, und nur mit Software und Binärdateien, die Sie installieren dürfen. Es dient nicht dazu, Lizenzen, Zugriffskontrollen, Providerbeschränkungen, Unternehmensrichtlinien oder Schutzmechanismen von Spielen und Anwendungen zu umgehen. Beschränken Sie RDP- und Emulatorordner-Zugriff, senden Sie keine Zugangsdaten oder privaten Hostdaten in Supportkanäle und dokumentieren Sie Installationen für eine reproduzierbare Verwaltung.

Neuromedia-Skripte und -Dokumentation stehen unter der [MIT-Lizenz](../LICENSE). LDPlayer und Mesa sind Drittprodukte mit eigenen Bedingungen. Dieses Projekt ist weder mit LDPlayer noch mit Mesa verbunden und wird von ihnen nicht unterstützt oder empfohlen. Für zulässige Zusammenarbeit zu Windows-Automatisierung, reproduzierbaren Anleitungen oder dokumentierten Installationspfaden: [Telegram](https://t.me/TheBotsLab) oder `BotsLab@proton.me`.

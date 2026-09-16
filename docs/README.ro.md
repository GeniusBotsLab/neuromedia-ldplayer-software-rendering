# Neuromedia LDPlayer Software Rendering

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **Stare:** set de instrumente numai cu cod sursă. Depozitul public conține scripturi și documentație, dar nu include DLL-uri Mesa de la terți.

## Scopul proiectului

Neuromedia LDPlayer Software Rendering ajută la pregătirea unui mediu Windows pentru rularea LDPlayer 14 pe o mașină fără placă video discretă adecvată sau pe un server administrat prin RDP. În această configurație, emulatorul Android poate să nu obțină un context OpenGL utilizabil, să rămână blocat la pornire, să se închidă sau să afișeze o fereastră neagră. Abordarea proiectului este să utilizeze randarea software Mesa/llvmpipe **în directoarele LDPlayer**, nu să instaleze sau să înlocuiască stiva grafică a întregului sistem Windows.

Acesta nu este un emulator, un pachet LDPlayer modificat și nici o imagine Android modificată. Este o colecție de scripturi PowerShell/CMD deschise și instrucțiuni reproductibile. Scopul este copierea DLL-urilor Mesa pe care operatorul le-a obținut și verificat deja în directoarele corecte, verificarea arhitecturii fișierelor și setarea `GALLIUM_DRIVER=llvmpipe`. Randarea software folosește CPU-ul; poate permite pornirea în lipsa unui GPU compatibil sau accesibil, însă nu promite performanță ridicată, compatibilitate cu toate aplicațiile, jocurile sau imaginile Android și nici suport din partea producătorilor.

## Ce fac scripturile

`1_INSTALL.cmd` este punctul de intrare pentru instalare și pornește `install.ps1` cu solicitare de drepturi de administrator. Scriptul verifică directoarele LDPlayer așteptate, oprește procesele asociate, elimină numai fișierele sau legăturile Mesa pe care le identifică, copiază DLL-urile x86 și x64 către destinațiile potrivite și setează variabila de mediu la nivel de sistem. La final afișează un rezultat de diagnostic. Nu îl rulați fără verificare pe un server de producție: confirmați căile, creați copii de siguranță și programați o fereastră de mentenanță.

`2_CHECK.cmd` rulează doar verificarea și nu ar trebui să modifice fișiere. Acesta indică dacă DLL-urile necesare au fost găsite, dacă arhitectura lor corespunde procesului țintă și dacă variabila de sistem este configurată. Folosiți-l înainte de instalare, după actualizarea LDPlayer și când investigați un eșec de pornire. O actualizare sau reinstalare LDPlayer poate înlocui fișierele din directoarele aplicației, caz în care instalarea și verificarea trebuie repetate.

## Cerințe și pregătire

Proiectul este conceput pentru LDPlayer 14 și utilizează implicit căile definite în `install.ps1`:

```text
D:\LDPlayer\LDPlayer14\              # DLL-uri x86 pentru dnplayer.exe
C:\Program Files\ldplayer9box\       # DLL-uri x64 pentru Ld9BoxHeadless.exe
```

Dacă LDPlayer este instalat în altă locație, deschideți `install.ps1` înainte de rulare și modificați variabilele `$ld` și `$box`. Nu înlocuiți fișierele x86 cu cele x64 și nici invers: arhitectura este esențială, iar o combinație greșită poate împiedica pornirea. Închideți emulatorul și toate procesele auxiliare, inclusiv pe cele care pot rula într-o altă sesiune RDP. Verificați drepturile de administrator și spațiul disponibil pentru backup.

Modificarea unei variabile de mediu de sistem nu actualizează procesele deja pornite. Deconectați-vă și reconectați-vă la RDP sau reporniți controlat serverul înainte de testare. Începeți cu o instanță de probă și o sarcină ușoară. Monitorizați CPU-ul și memoria: llvmpipe mută activitatea grafică pe procesor și poate afecta serviciile care rulează pe același server.

## DLL-uri Mesa de la terți și licențe

Un set privat inițial conținea binare Mesa fără fișier de licență inclus, link oficial de distribuție sau lanț de proveniență verificabil. Din acest motiv DLL-urile sunt excluse intenționat din acest depozit public. Nu redistribuiți binare terțe opace doar pentru că au funcționat într-un anumit mediu.

Obțineți build-uri Windows Mesa compatibile dintr-o sursă cu condiții clare de redistribuire. Păstrați licența, avizele și URL-ul sursei împreună cu pachetul; scanați fișierele cu instrumentele de securitate și verificați sumele de control. Puneți cele trei DLL-uri necesare pentru fiecare arhitectură în `mesa/x86/` și `mesa/x64/`, conform [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md). Informațiile de licențiere Mesa sunt disponibile la <https://docs.mesa3d.org/license.html>. Această pagină nu autorizează automat redistribuirea oricărui arhivă descărcată de pe internet.

## Operare sigură și revenire

Înainte de modificare, documentați starea inițială, faceți backup directoarelor afectate și limitați accesul RDP și permisiunile NTFS la administratori autorizați. Nu trimiteți în canale publice parole, acces RDP, IP-uri private, date ale clienților sau executabile neverificate. Automatizarea trebuie să respecte licențele, politicile organizației, cerințele furnizorului și controalele de securitate; proiectul nu este destinat ocolirii acestora.

Pentru revenire, închideți LDPlayer și eliminați din ambele directoare țintă DLL-urile instalate `opengl32.dll`, `libgallium_wgl.dll` și `libglapi.dll`; apoi ștergeți variabila de sistem `GALLIUM_DRIVER`. Restaurați backupul dacă este cazul. Comentariile din `install.ps1` descriu pașii manuali. Dacă nu sunteți sigur că un fișier aparține Mesa, nu îl ștergeți: păstrați o copie și verificați mai întâi proveniența, semnătura și data.

## Colaborare, autor și limite

Neuromedia este deschisă discuțiilor despre automatizarea permisă a mediilor Windows, documentație reproductibilă, adaptarea la căi de instalare documentate și integrare sigură în procese tehnice. Contact: [Telegram](https://t.me/TheBotsLab) sau `BotsLab@proton.me`.

Scripturile și documentația Neuromedia din acest depozit sunt distribuite sub [licența MIT](../LICENSE). LDPlayer este un produs terț; Mesa și DLL-urile sale sunt componente terțe cu propriile condiții. Proiectul nu este afiliat cu LDPlayer sau Mesa și nu pretinde că autorii acestora susțin ori aprobă această configurație.

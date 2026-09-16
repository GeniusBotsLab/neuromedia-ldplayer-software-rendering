# Neuromedia LDPlayer Software Rendering

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **Statut : boîte à outils avec sources uniquement.** Ce dépôt public contient des scripts et de la documentation, mais aucune DLL Mesa tierce.

## Objectif

Neuromedia LDPlayer Software Rendering est un petit ensemble d’outils destiné à préparer Windows pour l’exécution de LDPlayer 14 lorsqu’aucun GPU adapté n’est présent, accessible ou utilisable dans une session de bureau à distance. Cela peut concerner un serveur joint par RDP, une machine virtuelle sans passthrough GPU, ou un hôte dont le pilote graphique n’expose pas le chemin OpenGL attendu par l’émulateur. Dans ces situations, LDPlayer peut se fermer au démarrage, rester bloqué sur une fenêtre vide ou ne jamais amener l’instance Android à l’état prêt.

L’approche du projet est volontairement limitée : le rendu logiciel Mesa/llvmpipe est utilisé **dans les dossiers de LDPlayer**, sans remplacer la pile graphique de tout Windows. Le pilote llvmpipe effectue le rendu sur le CPU. Il peut rendre le démarrage possible quand l’accélération matérielle ne l’est pas, mais il ne garantit ni les performances en jeu, ni une faible latence, ni la compatibilité avec chaque image Android ou application. Considérez-le comme une solution de repli maîtrisée et testez la charge réelle.

Ce dépôt n’est ni un émulateur Android, ni une version reconditionnée ou modifiée de LDPlayer. Il propose une automatisation PowerShell/CMD lisible et des consignes pour placer les DLL Mesa fournies et vérifiées par l’utilisateur aux bons emplacements, contrôler leur architecture et définir `GALLIUM_DRIVER=llvmpipe` au niveau système.

## Rôle des scripts

`1_INSTALL.cmd` lance `install.ps1` avec une demande d’élévation de privilèges. Le programme d’installation vérifie la présence des répertoires LDPlayer attendus, arrête les processus liés à LDPlayer, retire seulement les fichiers Mesa ou liens qu’il détecte, copie les DLL x86 et x64 préparées vers leurs destinations, définit la variable système et affiche un diagnostic. Il modifie des fichiers applicatifs et des processus en cours : prévoyez donc une fenêtre de maintenance et des sauvegardes avant la première exécution sur un serveur de production.

`2_CHECK.cmd` est le point d’entrée de vérification non destructif. Il indique si les fichiers requis sont présents, si leur architecture correspond aux processus cibles et si la variable système est configurée. Exécutez-le après l’installation, après une mise à jour de LDPlayer et dès que le comportement de démarrage change. Une mise à jour ou une réparation peut remplacer les fichiers de l’application ; une configuration auparavant fonctionnelle peut alors devoir être réinstallée.

## Prérequis et préparation

Les chemins par défaut de `install.ps1` visent LDPlayer 14 :

```text
D:\LDPlayer\LDPlayer14\              # DLL x86 pour dnplayer.exe
C:\Program Files\ldplayer9box\       # DLL x64 pour Ld9BoxHeadless.exe
```

Si votre installation utilise d’autres dossiers, modifiez `$ld` et `$box` dans `install.ps1` avant toute exécution. Vérifiez les noms d’exécutables et les répertoires directement sur la machine cible au lieu de reproduire des hypothèses prises sur un autre serveur. N’intervertissez jamais les architectures : un processus 32 bits exige des DLL 32 bits et un processus 64 bits des DLL 64 bits. Une DLL incorrecte peut empêcher complètement le lancement.

Fermez LDPlayer et les outils associés, puis prévenez les utilisateurs d’un hôte partagé. L’installateur pouvant arrêter des processus, ne l’exécutez pas pendant une tâche d’automatisation active. Après la modification d’une variable d’environnement système, une nouvelle connexion RDP ou un redémarrage est généralement nécessaire pour que tous les nouveaux processus reçoivent cette valeur. Conservez une copie des répertoires cibles initiaux et notez la source, la version, les sommes de contrôle et la date d’installation des DLL.

## Binaires Mesa, provenance et licences

Les binaires Mesa tiers sont intentionnellement absents de ce dépôt public. Le paquet privé d’origine contenait des DLL sans fichier de licence joint, lien de distribution officiel ou chaîne de provenance vérifiable. Il serait inapproprié de publier des binaires opaques dont les conditions de redistribution sont inconnues.

Procurez-vous des builds Mesa compatibles pour Windows uniquement auprès d’une source aux conditions de distribution explicites. Conservez les fichiers de licence et d’avertissement, vérifiez les sommes de contrôle publiées lorsqu’elles existent, analysez l’archive suivant les règles de votre organisation, puis placez les trois DLL nécessaires pour chaque architecture dans `mesa/x86/` et `mesa/x64/`. Consultez [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md) avant de remplir ces dossiers. Les informations de licence Mesa sont disponibles sur <https://docs.mesa3d.org/license.html> ; cette page n’autorise pas à elle seule la redistribution de toute archive trouvée en ligne.

## Vérification, diagnostic et retour arrière

Commencez avec `2_CHECK.cmd`, puis lancez LDPlayer seulement lorsque les chemins et architectures affichés semblent corrects. Si l’échec persiste, recueillez la sortie de vérification, la version exacte de LDPlayer, la version de Windows, la méthode de lancement et les journaux applicatifs pertinents. Vérifiez qu’aucune ancienne `opengl32.dll`, `libgallium_wgl.dll` ou `libglapi.dll` ne subsiste dans le mauvais dossier cible. Ne désactivez pas la protection des terminaux ou la sécurité Windows uniquement pour faire un essai ; examinez plutôt la provenance et la signature des fichiers.

Pour revenir en arrière, fermez LDPlayer, retirez les fichiers Mesa installés des deux dossiers cibles et supprimez la variable système `GALLIUM_DRIVER`. Les commentaires de `install.ps1` détaillent la procédure manuelle. Si un fichier d’origine existait, restaurez-le depuis la sauvegarde. Si vous ne pouvez pas identifier avec certitude un fichier comme composant Mesa installé, ne le supprimez pas : gardez-en une copie et établissez d’abord son origine.

## Exploitation sûre et limites

Utilisez cet ensemble uniquement sur les systèmes que vous administrez et avec des logiciels et binaires que vous êtes autorisé à installer. Il ne doit pas servir à contourner des licences, contrôles d’accès, restrictions de fournisseurs, politiques d’entreprise ou protections de jeux et d’applications. Limitez l’accès RDP et l’accès aux dossiers de l’émulateur, ne transmettez ni identifiants ni données privées de l’hôte sur des canaux d’assistance, et documentez les déploiements pour qu’ils restent reproductibles.

Les scripts et la documentation Neuromedia sont proposés sous [licence MIT](../LICENSE). LDPlayer et Mesa sont des produits tiers soumis à leurs propres conditions. Ce projet n’est ni affilié à LDPlayer ou Mesa, ni approuvé ou pris en charge par eux. Pour une collaboration autorisée sur l’automatisation Windows, des instructions reproductibles ou des chemins d’installation documentés : [Telegram](https://t.me/TheBotsLab) ou `BotsLab@proton.me`.

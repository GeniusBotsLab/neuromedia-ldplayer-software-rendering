# Neuromedia LDPlayer Software Rendering

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **Status:** toolkit somente de código-fonte. O repositório público contém scripts e documentação, mas não inclui DLLs Mesa de terceiros.

## Objetivo do projeto

O Neuromedia LDPlayer Software Rendering ajuda a preparar um ambiente Windows para executar o LDPlayer 14 em uma máquina sem uma GPU discreta apropriada, inclusive em servidor acessado por RDP. Nessa situação, o emulador Android pode não obter um contexto OpenGL utilizável, travar no início, encerrar inesperadamente ou apresentar uma tela preta. A abordagem deste projeto é utilizar a renderização por software Mesa/llvmpipe **dentro das pastas do LDPlayer**, e não alterar a pilha gráfica de todo o sistema operacional.

Isto não é um emulador, um repack do LDPlayer nem uma imagem Android modificada. Trata-se de scripts PowerShell/CMD abertos e instruções claras para instalar DLLs Mesa que o próprio operador obteve e verificou, conferir a arquitetura dos arquivos e configurar `GALLIUM_DRIVER=llvmpipe`. A renderização por software usa a CPU. Ela pode tornar possível iniciar o emulador quando a GPU está ausente ou indisponível, mas não promete desempenho alto, compatibilidade com todos os jogos, aplicativos e imagens Android, nem suporte oficial de fabricantes.

## O que os scripts fazem

`1_INSTALL.cmd` é o ponto de entrada da instalação e inicia `install.ps1` com solicitação de privilégios de administrador. O script confere a existência das pastas esperadas do LDPlayer, encerra processos relacionados, remove apenas arquivos ou links Mesa identificados, copia DLLs x86 e x64 para os destinos corretos e define a variável de ambiente do sistema. Ao terminar, ele apresenta informações de diagnóstico. Não o execute sem revisão em um servidor de produção: confirme os caminhos, faça backup e programe uma janela de manutenção.

`2_CHECK.cmd` roda somente a verificação e não deve alterar arquivos. Ele informa se as DLLs esperadas foram encontradas, se a arquitetura é compatível com o processo de destino e se a variável do sistema está configurada. Execute-o antes da instalação, após atualizar o LDPlayer e ao investigar falhas de inicialização. Uma atualização ou reinstalação do LDPlayer pode substituir arquivos nas pastas do produto; nesse caso, instale novamente e confirme o resultado.

## Requisitos e preparação

O projeto foi preparado para o LDPlayer 14 e usa, por padrão, os caminhos definidos em `install.ps1`:

```text
D:\LDPlayer\LDPlayer14\              # DLLs x86 para dnplayer.exe
C:\Program Files\ldplayer9box\       # DLLs x64 para Ld9BoxHeadless.exe
```

Se o LDPlayer estiver instalado em outro local, abra `install.ps1` e ajuste as variáveis `$ld` e `$box` antes de executar os scripts. Nunca substitua arquivos x86 por x64, ou o contrário: a arquitetura é obrigatória e uma combinação incorreta pode impedir a inicialização. Feche o emulador e todos os processos auxiliares, inclusive os abertos em outra sessão RDP. Verifique privilégios administrativos e espaço disponível para backups.

Uma alteração em variável de ambiente de sistema não afeta processos já abertos. Saia da sessão RDP e entre novamente, ou reinicie o servidor de forma planejada, antes de testar. Comece com uma instância de teste e uma carga leve. Acompanhe CPU e memória, pois llvmpipe transfere trabalho gráfico para a CPU e pode reduzir os recursos disponíveis para outros serviços.

## DLLs Mesa de terceiros e licenças

Um conjunto privado original continha binários Mesa sem arquivo de licença, link oficial de distribuição ou cadeia de procedência verificável. Por isso, as DLLs foram deliberadamente excluídas deste repositório público. Não redistribua binários de terceiros sem origem e condições de publicação confirmadas apenas porque funcionaram em um ambiente.

Obtenha builds Windows compatíveis do Mesa em uma fonte com termos claros de redistribuição. Guarde licença, avisos e URL da origem; examine os arquivos com suas ferramentas de segurança e valide os checksums. Coloque as três DLLs exigidas de cada arquitetura em `mesa/x86/` e `mesa/x64/`, conforme [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md). As informações de licença do Mesa estão em <https://docs.mesa3d.org/license.html>. Essa referência não autoriza automaticamente a redistribuição de qualquer arquivo encontrado na internet.

## Operação segura e reversão

Antes da alteração, registre o estado original, faça backup dos diretórios afetados e restrinja RDP e permissões NTFS a administradores autorizados. Não envie senhas, acesso RDP, IPs privados, dados de clientes ou executáveis não verificados por canais públicos. A automação deve obedecer licenças, políticas da organização, regras do provedor e controles de segurança; este projeto não é um meio de contorná-los.

Para reverter, feche o LDPlayer e remova dos dois diretórios de destino as DLLs instaladas `opengl32.dll`, `libgallium_wgl.dll` e `libglapi.dll`; depois exclua a variável de sistema `GALLIUM_DRIVER`. Restaure o backup quando necessário. Os comentários em `install.ps1` descrevem as etapas manuais. Se houver dúvida sobre a origem Mesa de um arquivo, não o exclua: preserve uma cópia e confirme origem, assinatura e data primeiro.

## Colaboração, autoria e limites

A Neuromedia está aberta a conversas sobre automação permitida em ambientes Windows, documentação reproduzível, adaptação a caminhos de instalação documentados e integração segura em fluxos técnicos. Contato: [Telegram](https://t.me/TheBotsLab) ou `BotsLab@proton.me`.

Os scripts e a documentação Neuromedia deste repositório são distribuídos sob a [licença MIT](../LICENSE). LDPlayer é produto de terceiros; Mesa e suas DLLs são componentes de terceiros com condições próprias. Este projeto não é afiliado ao LDPlayer ou ao Mesa e não afirma que seus autores o apoiem ou aprovem esta configuração.

# Neuromedia LDPlayer Software Rendering

[Русский](README.ru.md) · [English](README.en.md) · [简体中文](README.zh-CN.md) · [עברית](README.he.md) · [Français](README.fr.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Português (Brasil)](README.pt-BR.md) · [日本語](README.ja.md) · [العربية](README.ar.md) · [Українська](README.uk.md) · [Română](README.ro.md)

> **Estado:** kit de código fuente. El repositorio público contiene scripts y documentación, pero no incluye DLL de Mesa de terceros.

## Finalidad del proyecto

Neuromedia LDPlayer Software Rendering ayuda a preparar un entorno Windows para ejecutar LDPlayer 14 cuando no hay una GPU discreta adecuada o cuando la GPU no está disponible en una sesión remota. Es un caso frecuente en servidores administrados por RDP: el emulador Android puede no encontrar un contexto OpenGL utilizable y quedarse bloqueado, cerrarse durante el inicio o mostrar una ventana negra. La estrategia de este proyecto es usar el renderizado por software Mesa/llvmpipe **dentro de las carpetas de LDPlayer**, no instalar ni sustituir la pila gráfica de todo Windows.

No es un emulador, un paquete modificado de LDPlayer ni una imagen de Android. Es un conjunto de scripts abiertos de PowerShell y CMD con instrucciones reproducibles. Su objetivo es copiar DLL de Mesa que el operador ya haya obtenido y verificado a los directorios correctos, comprobar la arquitectura de cada archivo y definir `GALLIUM_DRIVER=llvmpipe`. LlvmPipe renderiza con la CPU; puede permitir el arranque donde no existe un GPU compatible, pero no garantiza buen rendimiento, compatibilidad con cada aplicación o juego, ni soporte del fabricante.

## Qué hacen los scripts

Ejecute `1_INSTALL.cmd` como punto de entrada de instalación. Este iniciará `install.ps1` con elevación de administrador. El script valida los directorios esperados de LDPlayer, cierra los procesos relacionados, elimina únicamente archivos o enlaces Mesa que pueda identificar, copia las DLL x86 y x64 a sus destinos correspondientes y configura la variable de entorno del sistema. Finalmente muestra un resultado de diagnóstico. No lo ejecute a ciegas en un servidor de producción: confirme rutas, cree una copia de seguridad y reserve una ventana de mantenimiento.

`2_CHECK.cmd` ejecuta el modo de comprobación y no debe modificar archivos. Informa si las DLL esperadas están presentes, si su arquitectura coincide con el proceso de destino y si la variable del sistema está definida. Úselo antes de una instalación, después de actualizar LDPlayer y al investigar un fallo de inicio. Una actualización o reinstalación de LDPlayer puede reemplazar los archivos de sus carpetas, por lo que quizá deba instalar de nuevo y verificar otra vez.

## Requisitos y preparación

El proyecto está orientado a LDPlayer 14 y, de forma predeterminada, a estas rutas definidas en `install.ps1`:

```text
D:\LDPlayer\LDPlayer14\              # DLL x86 para dnplayer.exe
C:\Program Files\ldplayer9box\       # DLL x64 para Ld9BoxHeadless.exe
```

Si su instalación usa otro directorio, abra `install.ps1` antes de ejecutar nada y ajuste las variables `$ld` y `$box`. No copie DLL x64 sobre los destinos x86 ni al revés: la arquitectura es esencial y una combinación errónea puede impedir el inicio. Cierre LDPlayer y sus procesos auxiliares; no deje instancias activas en otra sesión RDP. También compruebe que dispone de privilegios administrativos y de espacio para la copia de seguridad.

El cambio de una variable de entorno de ámbito sistema no actualiza procesos existentes. Cierre la sesión RDP y vuelva a entrar, o reinicie de manera planificada, antes de evaluar el resultado. Inicie primero una instancia de prueba con una carga sencilla. Vigile el consumo de CPU y memoria: el renderizado por software desplaza el trabajo gráfico a la CPU y puede afectar a otras cargas del servidor.

## DLL de Mesa de terceros y licencias

Un kit privado de origen contenía binarios Mesa, pero no aportaba un archivo de licencia, un enlace oficial de distribución ni una procedencia comprobable. Por ello las DLL se excluyen intencionadamente de este repositorio público. No distribuya binarios de terceros opacos solo porque funcionen en una máquina determinada.

Obtenga compilaciones Windows de Mesa compatibles desde una fuente con condiciones de redistribución claras. Conserve el archivo de licencia, avisos y URL de origen junto al paquete; examine los archivos con su solución de seguridad y verifique sumas de comprobación. Coloque las tres DLL requeridas de cada arquitectura en `mesa/x86/` y `mesa/x64/` según [THIRD_PARTY_BINARIES.md](../THIRD_PARTY_BINARIES.md). La información de licencia de Mesa está disponible en <https://docs.mesa3d.org/license.html>. Esa página no convierte automáticamente cualquier archivo descargado en un binario autorizado para redistribución.

## Operación segura y reversión

Antes de intervenir, documente el estado inicial, respalde los directorios que se modificarán y limite el acceso RDP y NTFS a administradores autorizados. No publique contraseñas, direcciones IP privadas, accesos RDP, datos de clientes ni ejecutables no verificados. La automatización debe respetar licencias, políticas corporativas, requisitos del proveedor y controles de seguridad; este proyecto no sirve para evitarlos.

Para revertir, cierre LDPlayer y elimine de ambos directorios de destino las DLL instaladas `opengl32.dll`, `libgallium_wgl.dll` y `libglapi.dll`; después elimine la variable de sistema `GALLIUM_DRIVER`. Restaure su copia de seguridad si corresponde. Los comentarios de `install.ps1` describen el procedimiento manual. Si no está seguro de que un archivo pertenezca a Mesa, no lo borre: haga una copia y compruebe primero su procedencia, firma y fecha.

## Colaboración, autoría y límites

Neuromedia acepta conversaciones sobre automatización permitida de entornos Windows, documentación reproducible, rutas de instalación documentadas e integración segura en procesos técnicos. Contacto: [Telegram](https://t.me/TheBotsLab) o `BotsLab@proton.me`.

Los scripts y la documentación de Neuromedia se distribuyen bajo la [licencia MIT](../LICENSE). LDPlayer es un producto ajeno; Mesa y sus DLL son componentes de terceros con sus propias condiciones. El proyecto no está afiliado a LDPlayer ni a Mesa, y no afirma que sus autores respalden o aprueben esta configuración.

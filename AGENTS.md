# EZOAuto - AI Development Rules

Este proyecto es un addon para The Elder Scrolls Online (ESO).

El entorno Lua de ESO es limitado y no equivale a Lua estandar. El objetivo es mantener un addon pequeno, estable y facil de integrar en `EZOTools` en el futuro.

## Alcance

- Addon independiente: `EZOAuto`.
- Panel LibAddonMenu como unica interfaz.
- Dos idiomas: ingles y espanol, con opcion `Automatico`.
- Sin menues laterales.
- Sin overlay.
- Sin keybindings.
- Sin interceptar input.
- Sin acciones automaticas no verificadas contra APIs reales de ESO.

## Reglas obligatorias

- No inventar APIs de ESO.
- No usar librerias externas salvo indicacion expresa.
- Usar correctamente `LibAddonMenu-2.0`; `LibChatMessage` es opcional.
- Mantener cambios pequenos y revisables.
- No anadir modulos heredados de `EZOTools` salvo necesidad clara.
- Si se anade un archivo runtime, anadirlo a `EZOAuto.txt` en orden logico.
- Evitar globals innecesarias; usar `EZOAuto = EZOAuto or {}`.
- Usar prefijo de eventos/globales propio: `EZOAuto_` o `EZOA_`.

## Versionado

Para cambios visibles del addon, actualizar version con:

- `.\tools\bump-version.ps1 -Patch`
- o `.\tools\bump-version.ps1 -Version x.y.z`

La version visible debe quedar sincronizada entre:

- `EZOAuto.txt` (`## Version`)
- `modules/core.lua` (`EZOAuto.ADDON_VERSION`)

`## AddOnVersion` debe incrementarse cuando cambia la version visible.

No adivinar `## APIVersion`; cambiarlo solo si el valor actual esta verificado.

Antes de commit, ejecutar:

- `.\tools\bump-version.ps1 -Check`
- `git diff --check`

## Localizacion

- Usar `lang/en.lua` y `lang/es.lua`.
- No hardcodear textos visibles en modulos.
- Usar IDs `EZOA_*`.
- Cada clave debe existir en ambos idiomas.

## Automatizaciones

Las casillas LAM guardan preferencias. Las acciones reales deben implementarse una por una, solo cuando la ruta de API de ESO este confirmada.

Al implementar una accion automatica:

- comprobar estado de combate si aplica;
- validar que el contexto del mercader es correcto;
- proteger contra ejecuciones repetidas;
- imprimir mensajes de error claros;
- no vender ni reparar nada fuera del caso configurado.

## No hacer

- No crear menu lateral.
- No crear `Bindings.xml`.
- No registrar keybindings.
- No tocar input global.
- No copiar overlay, gamepad dialogs, quick utility ni side menu desde `EZOTools`.
- No publicar en Discord sin autorizacion explicita.

## Checklist de pruebas

Siempre indicar:

- Carga del addon sin errores Lua.
- `/reloadui`.
- Apertura del panel de configuracion LAM.
- Persistencia de idioma.
- Persistencia de casillas.
- Teclado y gamepad sin cambios de input.

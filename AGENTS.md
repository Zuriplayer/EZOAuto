# EZOAuto - AI Development Rules


<!-- EZO-SHARED-LAM-START -->
## Estándar LAM compartido

Antes de crear o modificar ajustes LibAddonMenu, leer y aplicar:
`E:\DEV\EZOFamilyDocs\docs\ezo-lam-settings-style.md`

Las reglas específicas de este addon tienen prioridad. Si el archivo compartido
no está accesible, no modificar LAM e indicarlo explícitamente.
<!-- EZO-SHARED-LAM-END -->
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

## Documentacion

- Toda modificacion funcional, de configuracion, comportamiento, alcance o requisitos debe incluir en el mismo trabajo la revision y actualizacion de `README.md` y `README.es.md`.
- Mantener ambos README equivalentes y sincronizados; ninguno debe contener funciones, limites o requisitos que no coincidan con el codigo actual.
- Actualizar las secciones afectadas, no solo el changelog: funciones, limites de seguridad, requisitos, instalacion o pruebas cuando corresponda.
- Antes de cerrar cada cambio, comprobar expresamente que la informacion de ambos README sigue completa y actualizada.

## Visibilidad HUD/UI

Si en algun momento se anade un control visual propio del addon como HUD, overlay, indicador, alerta flotante, barra, icono movible o elemento persistente en pantalla:

- No dejarlo como `TopLevelWindow` suelta visible en todas las escenas.
- Registrarlo como fragmento de escena con `ZO_SimpleSceneFragment:New(control)` o `ZO_HUDFadeSceneFragment` si procede.
- Anadir el fragmento solo a `HUD_SCENE` y `HUD_UI_SCENE`.
- Mantener un guard central de contexto: solo permitir mostrar controles si la escena actual es `hud` o `hudui`.
- Si la escena actual no es `hud` ni `hudui`, cualquier `RefreshVisibility`, `Refresh` o `Update` debe hacer `SetHidden(true)` y no volver a mostrar el control.
- Registrar `SCENE_MANAGER:RegisterCallback("SceneStateChanged", ...)` para refrescar visibilidad de todos los modulos visuales al cambiar de escena.
- No resolverlo con una lista negativa de escenas como Tribute, Champion Points, inventario, mapas o crafting. La regla correcta es whitelist: visible solo en HUD/HUD_UI.
- Si hay modo mover/desbloquear, mostrar previsualizacion solo en HUD/HUD_UI.
- No tocar input, keybinds, navegacion ni vanilla UI salvo opcion explicita y verificada.
- Mantener textos localizados EN/ES y no hardcodear textos visibles.
- Antes de usar APIs nuevas de ESO, verificar en UESP ESO Data: https://esodata.uesp.net/current/index.html

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

<!-- EZO-ESO-UPDATE-START -->
## Baseline obligatorio de ESO

Antes de analizar, modificar, validar, versionar o publicar este proyecto, leer
`..\EZOFamilyDocs\docs\eso-updates\current.md` y aplicar la política enlazada.

Baseline vigente: `U51-PTS-v12.1.0`.

- La matriz por addon vive en `..\EZOFamilyDocs\data\eso-update-baseline.json`.
- U51 sigue siendo PTS provisional hasta que exista verificación explícita.
- No cambiar `## APIVersion` por inferencia; verificarla en el cliente o en una
  fuente fiable de API.
- Si estos archivos no están disponibles, detener el trabajo sensible a
  compatibilidad e indicar el bloqueo.

Fuente remota de respaldo:
https://github.com/Zuriplayer/EZOFamilyDocs/blob/main/docs/eso-updates/current.md
<!-- EZO-ESO-UPDATE-END -->

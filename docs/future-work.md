# Estado y pendientes

Este archivo recoge ideas que no deben implementarse hasta confirmar APIs reales de ESO, impacto en teclado/gamepad y encaje con la filosofia de EZOAuto.

## Validado en 0.1.15

- Carga del addon sin errores Lua.
- `/reloadui`.
- Apertura del panel LAM.
- Persistencia de idioma.
- Persistencia de casillas.
- Teclado y gamepad sin cambios de input.
- Visibilidad de grupo en PvE:
  - ocultar nombres y barras al estar en grupo;
  - ocultar nombres y barras solo en combate;
  - restaurar valores al salir de grupo, salir de combate o desactivar casillas.
- Visibilidad de grupo bloqueada en AvA y Battleground, restaurando cualquier valor gestionado por EZOAuto.

## Deconstruccion segura

Estado actual: EZOAuto puede previsualizar candidatos y preparar la cola de deconstruccion usando la interfaz de ESO. No pulsa el boton final ni destruye objetos automaticamente; la confirmacion final queda siempre en manos del usuario.

Validado:

- Deconstructor universal con inventario y banco.
- Estaciones normales: herreria, ropa, carpinteria, joyeria y encantamiento.
- Teclado y gamepad.
- Ruta actual de deconstruccion segura sin confirmacion final.
- Banco y banco ESO Plus sin anomalias observadas en la ruta actual.

Decision:

- Mantener el comportamiento actual: preparar la lista y dejar que el usuario ejecute la deconstruccion.
- No tratar el asistente de deconstruccion de forma especial salvo que aparezca una anomalia concreta.

## Chat de grupo

Estado actual: EZOAuto cambia al canal de grupo al entrar en grupo y tambien despues de `/reloadui` si ya estabas agrupado.

Validado:

- Entrada real en grupo desde personaje solo.
- `/reloadui` estando ya en grupo.
- No abre la caja de chat ni envia mensajes.

Decision:

- Sin pendiente activo. Se mantiene el comportamiento actual: no restaurar automaticamente el canal anterior al salir del grupo.

## Finder de grupo

Estado actual: EZOAuto acepta automaticamente confirmaciones LFG del Activity Finder si el usuario activa la casilla concreta y ESO informa un `LFG_ACTIVITY_*` compatible.

Implementado:

- Mazmorras normales.
- Mazmorras veteranas.
- Battlegrounds.
- Tales of Tribute casual.
- Tales of Tribute competitivo.
- Trials.
- Arenas.
- Archivo infinito.
- Visitas de casas.
- Exploracion.
- Aviso sonoro repetido mientras hay un ready check LFG pendiente, con intervalo configurable.
- Tamer local del aviso sonoro: un unico bucle activo, sin reabrir dialogos ni tocar `PLAYER_TO_PLAYER`.

Referencias revisadas:

- AutoReadyCheck 2.4.1 en ESOUI. Usa `EVENT_ACTIVITY_FINDER_STATUS_UPDATE`, `ACTIVITY_FINDER_STATUS_READY_CHECK`, `GetLFGReadyCheckActivityType()` y `AcceptLFGReadyCheckNotification()`.
- Bandits User Interface. Usa `EVENT_ACTIVITY_FINDER_STATUS_UPDATE` y `AcceptLFGReadyCheckNotification()` con retardo.
- LFG Auto Accept. Historico y popular, pero antiguo; util como precedente, no como patron principal.
- Group & Activity Finder Extensions 6.2.0. Su modulo `queue-extensions.lua` repite `SOUNDS.LFG_SEARCH_FINISHED` cada 2 segundos mientras `GetActivityFinderStatus()` sigue en `ACTIVITY_FINDER_STATUS_READY_CHECK` y `HasAcceptedLFGReadyCheck()` sigue falso.
- IsJusta Ready Check Tamer 2.1. Controla prompts temporizados con `PLAYER_TO_PLAYER:AddPromptToIncomingQueue`; se descarta copiarlo tal cual porque afecta dialogos vanilla mas alla del Activity Finder.

Decision para EZOAuto:

- No se aceptan ready checks genericos de grupo.
- El modulo Activity Finder no acepta votaciones, invitaciones normales de grupo ni expulsiones.
- No se crean keybinds, overlays, comandos ni ventanas.
- No se hookea `PLAYER_TO_PLAYER` ni se silencian prompts globales.
- Todas las opciones quedan desactivadas por defecto.

Estado de pruebas:

- Funcionamiento general correcto en pruebas. Quedan tipos concretos por probar individualmente en teclado y gamepad.
- Confirmar si "Group Finder" moderno de grupos personalizados emite `LFG_ACTIVITY_EXPLORATION`, `LFG_ACTIVITY_TRIAL`, `LFG_ACTIVITY_ARENA` u otro tipo diferente.
- Probar si el sonido elegido por ESO (`SOUNDS.LFG_SEARCH_FINISHED` con fallback `SOUNDS.LFG_READY_CHECK`) es el mas claro en combate.

## Invitaciones normales de grupo

Estado actual: implementada una casilla independiente y desactivada por defecto para aceptar invitaciones normales de cualquier jugador mediante `EVENT_GROUP_INVITE_RECEIVED`, `GetGroupInviteInfo()` y `AcceptGroupInvite()`.

Limites:

- Se vuelve a comprobar que la misma invitacion sigue pendiente antes de aceptarla.
- No usa `PLAYER_TO_PLAYER` ni modifica dialogos vanilla.
- No acepta ready checks de grupo ni solicitudes de duelo, comercio, Tales of Tribute, votacion o expulsion.
- No forma parte de las opciones del Activity Finder.

Estado de pruebas:

- Pendiente probar una invitacion real en teclado y gamepad, incluida la cancelacion o caducidad durante el retardo corto de aceptacion.

## Automatizaciones de entorno

Implementado:

- Ocultar mascota cosmetica al entrar en zonas conocidas de trial mediante `GetZoneId(GetUnitZoneIndex("player"))`, `GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET)` y `UseCollectible`.
- Cerrar libros automaticamente con `EVENT_SHOW_BOOK` y `SCENE_MANAGER:ShowBaseScene()`, dejando abrir el mismo interactuable en el segundo intento.

Referencias revisadas:

- Bandits User Interface. Oculta mascota en lobbies/trials con lista de zonas y `UseCollectible`; cierra libros con `EVENT_SHOW_BOOK`.
- CrutchAlerts. Confirma IDs de trials modernos: Lucent Citadel `1478` y Ossein Cage `1548`.

Decision para EZOAuto:

- No se reactivan mascotas al salir del trial.
- No se tocan asistentes, companeros ni mascotas de combate.
- Auto-cerrar libros queda como casilla desactivada por defecto.
- No ampliar de momento la retirada de mascota a arenas.

Estado de pruebas:

- Retirada de mascota en trial: parece funcionar; se deja como esta.
- Libros/lorebooks/estanterias: parece funcionar.

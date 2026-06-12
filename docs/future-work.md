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

Estado actual: EZOAuto puede previsualizar candidatos y preparar la cola de deconstruccion usando la interfaz de ESO. No pulsa el boton final ni destruye objetos automaticamente.

Validado:

- Deconstructor universal con inventario y banco.
- Estaciones normales: herreria, ropa, carpinteria, joyeria y encantamiento.
- Teclado y gamepad.
- Ruta actual de deconstruccion segura sin confirmacion final.

Pendiente:

- Confirmar la ruta segura para detectar asistente de deconstruccion si se quiere cubrir de forma explicita.
- Decidir si queda permanentemente como "preparar cola" o si alguna vez se analiza una confirmacion final. Por defecto, no automatizar la confirmacion final.

## Chat de grupo

Estado actual: EZOAuto cambia al canal de grupo al entrar en grupo y tambien despues de `/reloadui` si ya estabas agrupado.

Validado:

- Entrada real en grupo desde personaje solo.
- `/reloadui` estando ya en grupo.
- No abre la caja de chat ni envia mensajes.

Pendiente:

- Revisar si conviene restaurar el canal anterior al salir del grupo. No implementado por decision expresa pendiente.

## Finder de grupo

Idea nueva pendiente de analisis: aceptar automaticamente las confirmaciones del finder cuando el jugador entra en una actividad de grupo, incluyendo dungeon, trial y Battleground si ESO lo expone por la misma ruta o por rutas equivalentes.

Antes de implementar hay que confirmar:

- Que existe una API o evento real y seguro para detectar la confirmacion del finder.
- Que la accion de aceptar puede ejecutarse desde addon sin interceptar input global ni simular teclas.
- Que se distingue claramente una confirmacion del finder de otros dialogos del juego.
- Que se puede limitar a contextos configurados por el usuario: dungeon, trial, Battleground u otros.
- Que no acepta ready checks, invitaciones, colas o dialogos no relacionados.
- Que funciona igual en teclado y gamepad, o que se bloquea de forma conservadora donde no este verificado.
- Que se protege contra ejecuciones repetidas y estados incompletos.
- Que la opcion queda desactivada por defecto y con texto claro en LAM.

No implementar hasta revisar ESOUI, addons actualizados y documentacion de UESP/ESO API. Si la unica ruta posible exige tocar input, keybindings, dialogos globales no especificos o aceptar dialogos ambiguos, la funcion debe descartarse o quedar solo documentada.

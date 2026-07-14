# EZOAuto

EZOAuto es un addon beta pequeño para **The Elder Scrolls Online** que añade automatizaciones opcionales y conservadoras para tareas comunes de la interfaz.

Prefer English? Read the [README in English](README.md).
Soporte, comentarios, informes de errores y sugerencias: https://discord.gg/ekw8zUAcRm

El addon mantiene un alcance reducido a propósito:

- un único panel de ajustes con LibAddonMenu;
- ajustes agrupados por finalidad, con ayuda contextual en cada cabecera y campo;
- localización en inglés y español;
- sin menú lateral;
- sin overlay;
- sin keybindings;
- sin interceptar input global.

## Estado beta

EZOAuto está actualmente en beta. Las funciones son opcionales y reversibles, pero conviene probarlas con tu propia configuración, especialmente si usas otros addons de interfaz o inventario.

## Metadatos de versión

- Versión del addon: `0.1.20`
- AddOnVersion: `10020`
- APIVersion: `101049 101050`
- Estado: beta temprana

## Requisitos

- The Elder Scrolls Online
- LibAddonMenu-2.0

Opcionales:

- LibChatMessage
- LibDebugLogger / DebugLogViewer

## Funciones

Todas las automatizaciones están desactivadas por defecto, se pueden activar de forma independiente y sus ajustes se guardan por personaje.

### Automatización de mercader

- Vender, mediante opciones independientes, equipo ornamentado no robado, objetos de tipo Tesoro y objetos de tipo Basura.
- Reparar solo el equipo equipado, o el equipo equipado y el equipo reparable de la mochila.
- Omitir combate, peristas, objetos robados, bloqueados o protegidos, objetos de armería, objetos de compañero y objetos sin valor de venta.

### Chat de grupo

- Cambiar opcionalmente el canal activo al chat de grupo al entrar en un grupo.
- Aplicarlo también después de `/reloadui` si el personaje ya estaba agrupado.
- No abre la caja de chat, no envía mensajes y no restaura el canal anterior al salir del grupo.

### Invitaciones de grupo

- Aceptar opcionalmente invitaciones normales de cualquier jugador para unirse a un grupo.
- Comprobar de nuevo que sigue pendiente la misma invitación antes de aceptarla.
- Esta opción es independiente del Activity Finder y no acepta ready checks de grupo ni solicitudes de duelo, comercio, Tales of Tribute, votación o expulsión.

### Deconstrucción segura

EZOAuto puede mostrar en Debug Viewer una vista previa de candidatos seguros y preparar la lista propia de deconstrucción de ESO en el deconstructor universal y en estaciones normales de herrería, sastrería, carpintería, joyería y encantamiento.

- Permite elegir inventario y, cuando ESO los expone, banco y banco de ESO Plus.
- Permite elegir por separado armas, armaduras, joyería y glifos/runas.
- Rechaza objetos robados, bloqueados, protegidos, legendarios, ornamentados, de compañero o no deconstruibles.
- Rechaza equipo fabricado por jugadores; los glifos fabricados siguen siendo válidos para el flujo normal de extracción.
- Respeta el filtro de categoría activo en el deconstructor universal.

EZOAuto **no pulsa la confirmación final de deconstrucción** y no destruye objetos por sí mismo. La acción destructiva final queda siempre en manos del usuario.

### Activity Finder

- Opciones independientes de aceptación automática para mazmorras normales, mazmorras veteranas, Battlegrounds, Tales of Tribute casual y competitivo, trials, arenas, Archivo infinito, Visitas de casas y Exploración cuando ESO expone el tipo de actividad correspondiente.
- Sonido repetido opcional mientras hay un ready check del Activity Finder pendiente, con un intervalo configurable entre 2 y 15 segundos.
- Un único bucle local de sonido evita avisos duplicados sin modificar ni reabrir diálogos de ESO.
- Las opciones del Activity Finder no aceptan ready checks genéricos de grupo, votaciones, invitaciones normales de grupo ni expulsiones.

### Visibilidad de grupo

- Ocultar opcionalmente los nombres y barras de salud nativos de ESO para miembros del grupo mientras estás agrupado, o solo durante el combate.
- Comportamiento opcional para healer que muestra las barras de salud de compañeros heridos en PvE aunque esté activa la ocultación en combate.
- Los valores nativos gestionados se restauran al terminar la condición o desactivar la opción; las zonas PvP no se modifican.
- No crea HUD ni overlay propio.

### Automatizaciones de entorno

- Ocultar opcionalmente la mascota cosmética en zonas conocidas de trial.
- Cerrar libros automáticamente con un retardo breve, dejando abierto el mismo libro si se vuelve a abrir en pocos segundos para poder leerlo.

### Idioma y diagnóstico

- Selección automática del idioma del cliente, o textos del addon forzados a inglés o español.
- Registro técnico opcional mediante LibDebugLogger y DebugLogViewer; el chat normal queda reservado para mensajes funcionales.

## Límites de seguridad

EZOAuto evita automatizaciones amplias y no:

- crea keybindings;
- intercepta input;
- añade menú lateral ni overlay persistente;
- acepta solicitudes de duelo, comercio, Tales of Tribute, votación, expulsión u otros prompts sociales;
- acepta invitaciones normales de grupo salvo que esté habilitada su opción independiente;
- confirma acciones destructivas de deconstrucción;
- vende ni repara fuera de los casos configurados.

Todas las automatizaciones son opcionales y se pueden desactivar individualmente desde LibAddonMenu.

## Instalación

1. Instala la dependencia requerida, LibAddonMenu-2.0.
2. Copia la carpeta `EZOAuto` dentro de la carpeta de AddOns de ESO.
3. Activa EZOAuto desde la pantalla de complementos de ESO.
4. Configura las opciones desde el panel de ajustes de addons dentro del juego.

El panel agrupa los ajustes en General, Automatización de mercader, Automatización de grupo, Buscador de actividades, Visibilidad del grupo, Automatización del entorno, Deconstrucción y Depuración. Pasa el cursor por un icono informativo morado para consultar el contexto de la sección o por un campo para ver su ayuda específica.

## Notas de prueba

Antes de depender de una función, pruébala con tu configuración:

- carga del addon sin errores Lua;
- `/reloadui`;
- apertura correcta del panel de ajustes;
- persistencia del idioma;
- persistencia de casillas;
- las invitaciones normales de grupo siguen siendo manuales con la opción desactivada y se aceptan al activarla;
- las solicitudes de duelo, comercio, Tales of Tribute, votación, expulsión y ready checks de grupo permanecen intactas;
- teclado y gamepad siguen siendo utilizables.

## Notas de desarrollo

Este repositorio mantiene el addon pequeño y enfocado de forma intencional. Cualquier automatización nueva debe estar respaldada por APIs verificadas de ESO y permanecer como opción activable desde el panel de ajustes.

## Licencia

MIT. Ver [LICENSE](LICENSE).

# Deconstruccion automatica

Estado: fase 2 en preparacion. EZOAuto puede hacer una vista previa en Debug Viewer y tambien dejar candidatos seguros en la lista de deconstruccion de ESO. Todavia no pulsa el boton final ni destruye objetos por su cuenta.

Primero hay que probar bien las ventas de mercader. Esta funcion destruye objetos, asi que no debe entrar en el addon hasta tener confirmada la ruta de APIs de ESO y unas pruebas claras en teclado y gamepad.

## Referencia revisada

Referencia principal: DeconstructAll (+gamepad) 0.2.0, publicado en ESOUI por awfuldead.

Ideas utiles de DeconstructAll:

- Trabaja con deconstructor universal, herreria, ropa, madera y encantamiento.
- No deconstruye directamente al abrir; anade objetos a la lista de deconstruccion de la propia interfaz de ESO.
- Evita objetos legendarios.
- Evita objetos ornamentados.
- Respeta FCO ItemSaver si esta presente.
- En deconstructor universal respeta el filtro activo, para no mezclar categorias.
- Permite incluir objetos del inventario del personaje y tambien objetos del banco.
- Tiene codigo separado para teclado y gamepad.

Riesgos vistos en los comentarios de ESOUI:

- Si un addon toca la lista de deconstruccion estando en la pestana equivocada, puede romper filtros de otros addons como Advanced Filters.
- Iterar inventario por cuenta propia puede saltarse protecciones o filtros de otros addons.
- La compatibilidad con gamepad no debe asumirse; hay que probarla aparte.

Para EZOAuto no copiamos su enfoque de boton ni keybind. La filosofia aqui sigue siendo: una casilla LAM activa una tarea automatica, sin menus extra, sin overlay y sin tocar input.

## Comportamiento deseado

Nombre provisional:

- Espanol: Deconstruir objetos seguros en deconstructor
- Ingles: Deconstruct safe items at deconstructors

La accion se ejecutaria solo al abrir un deconstructor valido, incluyendo el asistente de deconstruccion si la API lo permite de forma limpia.

Condiciones minimas para aceptar un objeto:

- No fabricado por un jugador. API pendiente de confirmar antes de implementar.
- No bloqueado por el jugador.
- No protegido por sistemas conocidos del juego.
- Calidad inferior a legendaria.
- No ornamentado, porque esos objetos pertenecen a la venta automatica.
- No equipado.
- No de companion.
- No robado, salvo que en el futuro se defina una regla especifica.
- Debe pertenecer a una categoria activada por el usuario.
- Debe estar en una ubicacion activada por el usuario: inventario del personaje o banco.

La parte de banco queda marcada como investigacion obligatoria. DeconstructAll lo permite, pero antes de programarlo en EZOAuto hay que confirmar si la ruta de ESO distingue bien mochila, banco y banco de ESO Plus, y si el asistente de deconstruccion puede acceder a banco igual que una estacion normal.

## Selectores posibles

No conviene una unica casilla gigante. Mejor una casilla maestra y selectores por familia:

- Activar deconstruccion automatica.
- Incluir inventario del personaje.
- Incluir banco.
- Armas.
- Armaduras.
- Joyeria.
- Glifos/runas.

Opciones que quedan para mas adelante:

- Incluir objetos intrincados aunque no sean de la familia marcada.
- Respetar FCO ItemSaver si esta cargado, sin convertirlo en dependencia obligatoria.

## Ruta tecnica propuesta

Fase 1: deteccion sin accion.

- Detectar entrada en estacion/deconstructor.
- Confirmar si es deconstruccion real y no refinado, mejora, creacion ni investigacion.
- Escribir en Debug Viewer cuantos candidatos habria, sin tocar objetos.

Implementado inicialmente para deconstructor universal y para vista previa en estaciones normales al entrar en modo deconstruccion/extraccion. En estaciones normales se limita el escaneo al `craftingType` de la estacion abierta para no contar objetos que solo podrian deconstruirse en otra mesa.

Fase 2: filtros.

- Implementar una funcion unica de candidato.
- Rechazar todo lo dudoso antes de mirar categorias.
- Registrar en Debug Viewer por que se descarta un objeto cuando el modo depuracion esta activo.

Fase 3: accion real.

- Usar los controles/rutas oficiales de ESO para anadir objetos a la deconstruccion.
- No usar keybinds.
- No pulsar botones por el usuario.
- No forzar pestanas sin verificar el estado exacto de la interfaz.
- Probar teclado y gamepad por separado.

Implementado inicialmente como preparacion de cola: se llama a `AddItemToCraft(bagId, slotIndex)` sobre el control de ESO que ya esta abierto. En deconstructor universal se respeta el filtro activo con `ZO_UniversalDeconstructionPanel_Shared.DoesItemPassFilter`, igual que la referencia revisada. Queda fuera, a proposito, pulsar el boton final de deconstruccion.

## Pendientes antes de programar

- Confirmar la API correcta para saber si un objeto fue fabricado por un jugador.
- Confirmar la API segura para detectar el asistente de deconstruccion.
- Confirmar la forma correcta de anadir objetos a la lista de deconstruccion sin interferir con filtros.
- Confirmar como maneja ESO los objetos del banco en deconstruccion y si hay diferencias entre estacion normal y asistente.
- Confirmar si banco de cuenta, banco de ESO Plus o banco de casas aparecen como bolsas distintas o solo como parte del filtro de deconstruccion.
- Decidir si la accion solo selecciona objetos o tambien confirma la deconstruccion.
- Decidir si se respeta FCO ItemSaver solo si esta cargado.

Fuentes:

- https://www.esoui.com/downloads/info3667-DeconstructAllgamepad.html
- https://cdn.esoui.com/downloads/file3667/DeconstructAll.zip?171049946115

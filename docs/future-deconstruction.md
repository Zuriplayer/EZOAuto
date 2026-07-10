# Deconstruccion automatica

Estado: implementado como preparacion de cola. EZOAuto puede hacer una vista previa en Debug Viewer y tambien dejar candidatos seguros en la lista de deconstruccion de ESO. No pulsa el boton final ni destruye objetos por su cuenta; esa confirmacion queda siempre en manos del usuario.

## Referencia revisada

Referencia principal: DeconstructAll (+gamepad) 0.2.0, publicado en ESOUI por awfuldead.

Ideas utiles de DeconstructAll:

- Trabaja con deconstructor universal, herreria, ropa, madera y encantamiento.
- No deconstruye directamente al abrir; anade objetos a la lista de deconstruccion de la propia interfaz de ESO.
- Evita objetos legendarios.
- Evita objetos ornamentados.
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

La accion se ejecuta solo al abrir una ruta de deconstruccion/extraccion valida. El asistente de deconstruccion queda sin tratamiento especial salvo que aparezca una anomalia concreta.

Condiciones minimas para aceptar un objeto:

- No fabricado por un jugador, salvo glifos/runas en encantamiento, donde crear glifos basicos para extraer es una ruta de uso esperada.
- No bloqueado por el jugador.
- No protegido por sistemas conocidos del juego.
- Calidad inferior a legendaria.
- No ornamentado, porque esos objetos pertenecen a la venta automatica.
- No equipado.
- No de companion.
- No robado, salvo que en el futuro se defina una regla especifica.
- Debe pertenecer a una categoria activada por el usuario.
- Debe estar en una ubicacion activada por el usuario: inventario del personaje o banco.

El banco y banco ESO Plus no han mostrado anomalias en la ruta actual. Si aparece una diferencia entre estacion normal y asistente, se documentara como caso concreto.

## Selectores posibles

No conviene una unica casilla gigante. Mejor una casilla maestra y selectores por familia:

- Activar deconstruccion automatica.
- Incluir inventario del personaje.
- Incluir banco.
- Armas.
- Armaduras.
- Joyeria.
- Glifos/runas.

Opciones descartadas:

- Incluir objetos intrincados con una regla especial.
- Integracion con FCO ItemSaver.

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

## Decisiones y seguimiento

- Mantener el alcance actual: seleccionar/preparar candidatos seguros, sin confirmar la deconstruccion.
- Mantener el asistente de deconstruccion sin logica diferenciada mientras no haya una anomalia reproducible.
- Banco y banco ESO Plus quedan aceptados en la ruta actual al no haberse observado anomalias.

Fuentes:

- https://www.esoui.com/downloads/info3667-DeconstructAllgamepad.html
- https://cdn.esoui.com/downloads/file3667/DeconstructAll.zip?171049946115

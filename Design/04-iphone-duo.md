# iPhone Duo

Resumen de lo que dice la documentación de Apple (HIG "Designing for iPhone Duo" y la documentación de SwiftUI) y de cómo lo aplica el diseño de Midgray. Las seis posturas están dibujadas en Figma, sección "iPhone Duo".

> Verificar antes de programar: la disponibilidad exacta de cada API (versión mínima de iOS) en la documentación de Xcode. Midgray apunta a iOS 26; las APIs de Duo se usarán con `#available` si exigen una versión posterior.

## Qué dice Apple

- Dos pantallas: externa (ancho compacto) e interna (ancho regular), con una bisagra central.
- **No se diseña una disposición por postura.** Se usan size classes, márgenes y safe areas, y se evitan los anchos fijos.
- Controles en el lateral: en la pantalla externa y en la interna en horizontal, la barra del sistema (isla dinámica, estado, barras de herramientas) va en una **barra vertical** de unos 84 pt a la derecha. En la interna en vertical se mantienen las barras horizontales.
- **Regiones reservadas:** la cámara frontal externa (siempre) y la **región de pliegue**, que divide la pantalla interna cuando está parcialmente abierta (horizontal en vertical, vertical en horizontal).
- No se debe depender de `UIScreen.main`, de la orientación ni del idiom para decidir el layout.

## APIs relevantes (SwiftUI)

| API | Para qué |
|---|---|
| `ArrangementView` con estilo `.overlay` | Primario encima del secundario. Parcialmente plegado, cada vista pasa a ocupar un lado. Es el patrón de Midgray |
| `ReservedRegion` | Mover contenido propio fuera de las regiones reservadas |
| `DeviceHinge` y `onHingeChange` | Ángulo y estado de la bisagra: cerrada, parcialmente abierta, abierta |
| Size classes y `safeAreaInsets` | Base de todo layout |
| `ToolbarItemGroup`, `ToolbarItemVisibilityPriority` | Barras que se adaptan y desbordan |

## Cómo lo aplica Midgray

- Estructura: `ArrangementView(.overlay)` con **secundario = vista previa de la cámara** y **primario = panel de controles**. Con el dispositivo abierto, el panel va sobre la cámara. Plegado, la cámara queda en un lado y los controles en el otro.
- Seis posturas dibujadas: externa vertical, externa horizontal, interna vertical, interna horizontal, interna vertical plegada (cámara arriba, controles abajo) e interna horizontal plegada (cámara a la izquierda, controles a la derecha).
- **Herramientas en la barra del sistema.** Ajustes, lente, tipo de medición y compensación de EV son elementos de la barra de herramientas (`ToolbarItem` con símbolo y título), no controles propios. El sistema los coloca en la barra vertical de la derecha (pantalla externa y pantalla interna en horizontal) o en la barra superior (pantalla interna en vertical). Orden: primero Ajustes (navegación), después las acciones frecuentes. Lo que no cabe pasa al menú de desbordamiento del sistema (`ToolbarItemVisibilityPriority`). Cada elemento lleva título además de símbolo. Así se libera la fila superior de la cámara y el panel queda solo con los valores de exposición y "Medir".
- Las mismas funciones en todas las posturas: no desaparecen controles, solo cambian de sitio. Los selectores de lente y medición se quedan sobre la cámara y el panel con los valores y "Medir" se desplaza.
- En pantalla interna ancha el panel no se estira: máximo ~520 pt.
- El texto y los controles mantienen el mismo tamaño entre posturas.

## Prueba

Device Hub de Xcode permite simular el iPhone Duo, con botones para cerrado, parcialmente abierto y abierto, y un control para plegar a cualquier ángulo (Opción + arrastrar).

## Pendiente

- Comprobar en Device Hub el comportamiento real de `ArrangementView(.overlay)` y qué eje elige el sistema en cada postura.
- Decidir si el panel con la lista de equivalentes se simplifica en la pantalla externa vertical.
- En horizontal externa, el selector "Velocidad" queda justo de ancho: ampliar el panel o abreviar.

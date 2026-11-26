# iPhone Duo

Resumen de lo que dice la documentación de Apple (HIG "Designing for iPhone Duo" y la documentación de SwiftUI) y de cómo lo aplica el diseño de Midgray. Las seis posturas están dibujadas en Figma, sección "iPhone Duo".

> Implementado. Las APIs de Duo (`ArrangementView`, `onHingeChange`, `axisBehavior`) requieren iOS 27.1. Midgray apunta a iOS 26, así que se usan con `#available` y en versiones anteriores la vista previa y los controles van en un `ZStack`.

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

## Implementación

- `MeterView` usa `ArrangementView(.overlay)`: primario = controles, secundario = vista previa. Plegado, el sistema pone los controles abajo o a la derecha (`overlayArrangementEdge`).
- `MeterLayout` decide la disposición a partir del tamaño que reciben los controles y el del contenedor, sin mirar orientación ni dispositivo:

| Caso | Cuándo | Disposición |
|---|---|---|
| `stacked` | Alto mayor que ancho, o menos de 560 pt de ancho | Panel completo abajo (máximo 520 pt) |
| `side` | Ancho mayor que alto y al menos 560 pt | Panel de 340 pt con valores en filas; equivalentes sobre la cámara |
| `bottomHalf` | Los controles reciben menos del 75 % del alto | Panel completo a todo el ancho, en la parte alta de la mitad inferior |
| `trailingHalf` | Los controles reciben menos del 75 % del ancho | Panel con filas a la derecha; equivalentes sobre la mitad de la cámara |

- El título de las equivalentes solo se muestra cuando la altura disponible es menor de 360 pt (iPhone en horizontal); en el Duo van solo los chips.
- La lente y la compensación son texto, y el sistema deja los elementos con texto en la barra horizontal. Por eso el grupo lleva `axisBehavior(.verticalPreferred)`.
- La vista previa gira con `AVCaptureDevice.RotationCoordinator`, y el punto de medición puntual vuelve al centro cuando cambia el tamaño.

## Diferencias con el diseño

- El panel lateral mide 340 pt en todos los casos (el diseño usa entre 320 y 347), para que «Velocidad» no salga cortado.
- En la pantalla externa horizontal caben menos equivalentes completas porque los chips reales son más anchos.
- La barra vertical sale a un lado u otro según el giro; lo decide el sistema.
- La lista de equivalentes no se simplifica en la pantalla externa vertical.

## Pendiente

- Probar en un iPhone Duo real: solo se ha verificado en el simulador, que no tiene cámara.
- En el simulador, los botones de la barra vertical aparecen vacíos un momento justo después de cambiar de postura y luego se dibujan. Comprobar si ocurre en el dispositivo.
- Revisar la pantalla de permiso de cámara en el Duo.

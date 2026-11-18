# Flujo de usuario y pantallas (v1.0)

Documentos relacionados: `01-references.md`, `03-tokens.md`, `04-iphone-duo.md`. El diseño visual vive en el archivo de Figma privado "Midgray - Wireframes", página "Diseño UI".

## Flujo

Primera apertura:
Onboarding (3 a 4 páginas) -> última página prepara y pide permiso de cámara -> Medidor

Aperturas siguientes:
Medidor (si el permiso está concedido) o Permiso denegado (si no)

Desde el Medidor:
- Medidor -> Ajustes -> Calibración
- Medidor -> Ajustes -> Ver tutorial (reabre el onboarding)
- Medidor -> botón de medición de la barra -> Promedio o Puntual; en Puntual, un toque en la vista previa coloca el retículo

## Inventario de pantallas

1. Onboarding: qué mide, cómo leer el resultado, modos de medición, calibración. Última página: permiso.
2. Permiso denegado o restringido: explica y lleva a Ajustes del sistema.
3. Medidor (principal): vista previa a pantalla completa y, sobre ella, el panel de vidrio con el modo de exposición (Auto, Apertura, Velocidad, ISO), los tres valores, el EV y "Medir". Las herramientas (Ajustes, lente, tipo de medición promedio o puntual y compensación de EV) son elementos de la barra de herramientas del sistema (`ToolbarItem`), iguales en todos los dispositivos: en iPhone van en la barra superior y en iPhone Duo el sistema las coloca en la barra vertical.
4. Ajustes: calibración (±EV), ver tutorial, acerca de, privacidad.
5. Calibración: ajuste manual con explicación breve.

## Modelo de interacción del Medidor (decidido)

- La app mide la luz de la escena con el iPhone, pero los valores sugeridos son para **la cámara del usuario** (la D5100, una película, otro teléfono). La apertura del iPhone no interviene en lo que el usuario ve.
- Hay un **selector de modo** con cuatro opciones. El modo por defecto al abrir la app es **Auto**. Sin perfiles de cámara ni de lente no sabemos la apertura máxima del usuario, así que el modo manda qué valor elige el usuario y cuál calcula la app.
- El **ISO** siempre es un ajuste visible (por defecto 100), porque todo exposímetro necesita saber la sensibilidad. Solo cambia cuando el modo es ISO.

| Modo | El usuario elige | La app calcula |
|---|---|---|
| Auto (por defecto) | ISO | Una combinación equilibrada y una lista de exposiciones equivalentes (cada apertura con su velocidad) |
| Apertura (A) | Apertura e ISO | Velocidad |
| Velocidad (S) | Velocidad e ISO | Apertura |
| ISO | Apertura y velocidad | ISO necesario |

- En Auto el usuario puede tocar una fila de la lista de equivalentes para pasar a ese par.
- Los valores que fija el usuario se ven como controles (se tocan y abren una rueda nativa). El valor calculado se ve distinto (solo lectura, más grande).
- Lectura en vivo con suavizado. El botón **Medir** retiene la lectura; un segundo toque vuelve a lectura en vivo.
- Modo **Promedio** o **Puntual**. En puntual, un toque en la vista previa coloca el retículo.

## Estados y casos borde

- Poca luz extrema o lectura fuera de rango.
- Sobreexposición.
- Lectura inestable.
- Sin cámara disponible.
- Permiso cambiado mientras la app estaba abierta.

## Orientación

- Vertical y horizontal desde v1.0. El Medidor está diseñado en ambas.

## Adaptación a iPhone Duo

- Seis posturas diseñadas: externa vertical y horizontal, interna vertical y horizontal, y las dos posturas plegadas. Detalle en `04-iphone-duo.md`.
- Las herramientas (Ajustes, lente, medición, compensación) van en la barra del sistema; el panel con valores y "Medir" se adapta al espacio disponible.
- Ningún diseño depende de un tamaño fijo.

## Compensación de EV

- El botón `±` de la barra abre un popover con el stepper de compensación (paso de 1/3 EV). El panel solo muestra el valor actual. Falta dibujar este popover.

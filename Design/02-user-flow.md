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

1. Onboarding: qué mide, modos de exposición, medición promedio o puntual y, la primera vez, una última página que pide el permiso de cámara. Se puede volver a ver desde Ajustes (sin la página del permiso).
2. Permiso de cámara (sin decidir, denegado o restringido): explica y, según el caso, pide el permiso o lleva a Ajustes del sistema. Mientras no se conoce el estado solo se ve el fondo negro.
3. Medidor (principal): vista previa a pantalla completa y, sobre ella, el panel de vidrio con el modo de exposición (Auto, Apertura, Velocidad, ISO), las exposiciones equivalentes (en Auto), los tres valores, el EV y "Medir". Las herramientas (Ajustes, lente, tipo de medición y compensación de EV) son elementos de la barra de herramientas del sistema: en iPhone van en la barra superior y en iPhone Duo el sistema las coloca en la barra vertical.
4. Cámara no disponible: si la cámara no se puede iniciar, el Medidor explica el problema y ofrece Reintentar.
5. Ajustes: Medición (calibración y lente predeterminada), Ayuda (ver tutorial y cómo leer la medición) y Acerca de (privacidad y versión).
6. Calibración: ajuste manual de −2 a +2 EV en pasos de 0,1, con explicación breve.

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

- En Auto el usuario puede tocar uno de los chips de exposiciones equivalentes para pasar a ese par.
- Los valores que fija el usuario se ven como controles: al tocarlos o deslizar sobre ellos abren una rueda propia (`ValueWheel`) en un popover del sistema, encima de la celda (al costado en horizontal y en el Duo plegado). El valor se aplica cuando la rueda se detiene, y la rueda se cierra sola o al tocar fuera. El valor calculado se ve distinto (solo lectura, fondo claro).
- Lectura en vivo con suavizado. El botón **Medir** retiene la lectura; un segundo toque vuelve a lectura en vivo.
- Modo **Promedio** o **Puntual**. En puntual, un toque en la vista previa coloca el retículo.

## Estados y casos borde

- Poca luz extrema o lectura fuera de rango.
- Sobreexposición.
- Lectura inestable.
- La cámara no se puede iniciar.
- Permiso cambiado mientras la app estaba abierta.

## Orientación

- Vertical y horizontal desde v1.0. En horizontal el panel va a la derecha con los valores en filas y las equivalentes abajo a la izquierda; el tutorial pone la ilustración junto al texto.

## Adaptación a iPhone Duo

- Seis posturas diseñadas: externa vertical y horizontal, interna vertical y horizontal, y las dos posturas plegadas. Detalle en `04-iphone-duo.md`.
- Las herramientas (Ajustes, lente, medición, compensación) van en la barra del sistema; el panel con valores y "Medir" se adapta al espacio disponible.
- Ningún diseño depende de un tamaño fijo.

## Compensación de EV

- El botón `±` de la barra abre un popover con una rueda de compensación (de −3 a +3 EV en pasos de 1/3). Cuando no es cero, el botón muestra el valor; el panel también lo muestra.

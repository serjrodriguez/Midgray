# Tokens y componentes del DesignSystem

Fuente: archivo de Figma privado "Midgray - Wireframes", página "Diseño UI", sección "Tokens del DesignSystem". Se usa la biblioteca oficial de Apple iOS 26 y solo componentes nativos con Liquid Glass.

## Color

Principio: usar colores semánticos del sistema y solo añadir los propios del Medidor, que vive sobre la cámara y siempre se ve oscuro.

| Token | SwiftUI | Uso |
|---|---|---|
| Backgrounds/Primary | `Color(.systemBackground)` | Fondo de onboarding y permiso denegado |
| Grouped/Primary | `Color(.systemGroupedBackground)` | Fondo de Ajustes y Calibración |
| Grouped/Secondary | `Color(.secondarySystemGroupedBackground)` | Tarjetas y filas agrupadas |
| Backgrounds/Secondary | `Color(.secondarySystemBackground)` | Tarjeta de ilustración |
| Accents/Blue | tint de la app | Acciones principales, símbolos |
| Labels/Primary | `.primary` | Texto principal |
| Labels/Secondary | `.secondary` | Texto de apoyo |

Propios de Midgray (Medidor):

| Token | Valor | Uso |
|---|---|---|
| Vidrio | `glassEffect(.regular)` | Paneles, chips y fondos de los selectores |
| Valor calculado | blanco al 92 % con texto oscuro | Resultado que calcula la app |
| Valor elegido | fondo blanco al 8 %, borde blanco al 55 % | Valor que fija el usuario |

## Tipografía

| Uso | SwiftUI | Estilo en Figma |
|---|---|---|
| Títulos de onboarding | `.largeTitle.bold()` | Large Title / Emphasized |
| Título de estado | `.title3.bold()` | Title 3 / Emphasized |
| Texto | `.body` | Body / Regular |
| Botones y filas | `.headline` | Headline / Regular |
| Valor de exposición | `.system(size: 24, weight: .semibold).monospacedDigit()` | propio |
| Valor en fila (horizontal) | tamaño 20, semibold | propio |
| Etiqueta de celda | `.caption2` | propio (11) |

Todo debe respetar Dynamic Type: los valores propios se definen con `@ScaledMetric` o estilos relativos.

## Espaciado y radios

**Espaciado: cuadrícula de 4 pt**, de 4 a 40: `s4, s8, s12, s16, s20, s24, s28, s32, s36, s40`. El nombre lleva el valor y se usa como `Spacing.s16`.

**Radios:** `r14` (chips y celdas en fila), `r16` (celda de valor), `r26` (tarjetas de grupo y hojas), `r34` (panel de vidrio) y `r36` (tarjeta del icono en onboarding). Se usan como `Radius.r16`. Las píldoras no son un token numérico: en SwiftUI son `Capsule()`.

**Convención:** `enum` sin casos como espacio de nombres, constantes `static let` de tipo `CGFloat`, tipo marcado como `nonisolated` y nombre con el valor (`s`, `r`) en lugar de `spacing_16`. Más adelante, una segunda capa con nombres de uso (por ejemplo `Radius.valueCell = r16`) para que las vistas no dependan de los números.

### Ajuste del diseño a la cuadrícula

El primer diseño usaba separaciones de 6 y 10 pt que no están en la cuadrícula. En código se redondean, y la diferencia es de 2 pt como máximo; el panel crece unos 8 pt en horizontal y cabe sin problema.

| En Figma | En código |
|---|---|
| 6 (separación entre chips y entre filas) | `s8` |
| 6 (etiqueta pequeña sobre su contenido) | `s4` |
| 10 (relleno de celdas y separación en el panel) | `s12` |

El archivo de Figma se actualizará a estos valores cuando se retoque el diseño; hasta entonces manda este documento.

## Componentes reutilizables (Core/DesignSystem)

| Componente | Figma |
|---|---|
| `ValueCell(kind: .input / .result)` y su variante en fila | Cell/Input, Cell/Result, y "(row)" |
| `EquivalentChip(isSelected:)` | Chip/Default, Chip/Selected |
| `GlassPanel { }` | Liquid Glass – Regular – Large |
| `PrimaryActionButton("Medir")` | Button – Liquid Glass – Text |
| `ExposureModePicker`, `MeteringPicker`, `LensPicker` | Segmented control |
| `CompensationStepper` | Stepper |
| `IconCard(symbol:)` | Ilustración de onboarding |

Regla: si un estilo se repite en dos vistas, sube a `Core/DesignSystem`.

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

- Espaciado: 4, 8, 12, 16, 24, 40.
- Radios: celda 14–16, hoja 26, panel de vidrio 34, píldora completa.

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

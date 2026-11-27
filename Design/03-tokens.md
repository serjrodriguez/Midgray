# Tokens y componentes del DesignSystem

Fuente: archivo de Figma privado "Midgray - Wireframes", página "Diseño UI", sección "Tokens del DesignSystem". Se usa la biblioteca oficial de Apple iOS 26 y solo componentes nativos con Liquid Glass.

## Color

La interfaz es siempre oscura, porque el Medidor vive sobre la cámara. Los colores propios están en `Core/DesignSystem/Tokens/Colors.swift`; el resto son del sistema.

| Token | Valor | Uso |
|---|---|---|
| Fondo | `Color.black` | Todas las pantallas |
| `meterAccent` | `Color.blue` | Tinte del cristal (chip seleccionado y botón principal). Fijo, para que no se atenúe bajo una hoja |
| Acento de la app | `Color.accentColor` | Símbolos y texto de acción |
| Texto | `.primary` / `.secondary` | Principal y de apoyo |
| `meterResultFill`, `meterResultText`, `meterResultSecondaryText` | blanco al 92 % con texto oscuro | Valor que calcula la app |
| `meterInputFill`, `meterInputBorder` | blanco al 8 % y borde al 55 % | Valor que fija el usuario |
| `meterWheelFill`, `meterWheelBand` | gris oscuro y blanco al 14 % | Rueda de valores y tarjetas |
| Vidrio | `glassEffect(.regular)` | Paneles, chips y barra |

## Tipografía

| Uso | SwiftUI |
|---|---|
| Títulos de onboarding | `.title.bold()` |
| Texto | `.body` / `.subheadline` |
| Botones | `.headline` |
| Valor de exposición | 24 pt semibold con dígitos monoespaciados |
| Valor en fila (horizontal y Duo) | 20 pt semibold |
| Etiqueta de celda | `.caption2` |

Todo respeta Dynamic Type: los tamaños propios usan `@ScaledMetric`.

## Espaciado y radios

**Espaciado: cuadrícula de 4 pt**, de 4 a 40: `s4, s8, s12, s16, s20, s24, s28, s32, s36, s40`. El nombre lleva el valor y se usa como `Spacing.s16`.

**Radios:** `r14` (banda central de la rueda), `r16` (celda de valor), `r26` (rueda y tarjeta de calibración), `r34` (panel de vidrio) y `r36` (tarjeta del icono en onboarding). Se usan como `Radius.r16`. Las píldoras (chips y botones) no son un token numérico: en SwiftUI son `Capsule()`.

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
| `ValueCell(kind: .input / .result)`; en fila con `usesCompactValues` | Cell/Input, Cell/Result, y "(row)" |
| `ValueWheel` | Edición de valores, opción F; presentada en popover, opciones G2 (vertical) y H1 (compacto) |
| `EquivalentChip(isSelected:)` | Chip/Default, Chip/Selected |
| `GlassPanel { }` | Liquid Glass – Regular – Large |
| `PrimaryActionButton` | Button – Liquid Glass – Text |

El selector de modo de exposición es un `Picker` segmentado del sistema; lente y medición son menús de la barra.

Regla: si un estilo se repite en dos vistas, sube a `Core/DesignSystem`.

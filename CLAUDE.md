# CLAUDE.md — Plantilla de Informes Técnicos · SLEP Chinchorro (Unidad TI)

> Este archivo orienta a **Claude Code** dentro de este repositorio. Su objetivo es que
> el usuario y Claude **redacten informes técnicos juntos** usando la plantilla `lib.typ`,
> que reproduce el estándar **TI-MAN-GOB_2026-0020 v2.0** (Manual de Normas Gráficas SLEP 2026).
> Lee este archivo completo antes de crear o editar documentos.

---

## 0. Cómo debe comportarse Claude en este repo

- **`lib.typ` es la plantilla (presentación). NO se edita su estilo** (colores, tipografía,
  portada, márgenes) salvo que el usuario lo pida explícitamente. Regla del manual §11.2.
- **Cada informe es un archivo `.typ` propio** que importa `lib.typ` y solo aporta `meta` + prosa.
- Al redactar, Claude **mapea el contenido del usuario a la estructura canónica** (§4) y
  **rellena `meta`** (§3); no inventa datos institucionales (usa los defaults de la plantilla).
- Tras cada cambio, **compila y verifica** (§6). No afirmar que algo funciona sin compilarlo.
- Diffs mínimos, una sola fuente de verdad (todo dato en `meta`), sin hardcodear estilos.

---

## 1. Estructura del proyecto

```
.
├── lib.typ          # PLANTILLA (motor): estilos, portada/contraportada, componentes, atajos.
├── main.typ         # Informe de ejemplo (referencia). No es la plantilla.
├── CLAUDE.md        # Este archivo.
└── Images/
    ├── logoslepch.png   # Logo color SLEP (portada + header)   ← meta.logos.slep
    └── isologo_2.png    # Marca pequeña (reservado)            ← meta.logos.isologo
```

Convención: crea cada informe como `TI-INF-<CAT>_<AAAA>-<NNNN>.typ` (mismo nombre que el
código base, sin versión/fecha) en la raíz del repo.

---

## 2. Inicio rápido — esqueleto de un informe

Crea `nuevo-informe.typ` con esta base (también está embebida en la cabecera de `lib.typ`):

```typst
#import "lib.typ": *

#let meta = crear-meta((
  area: "TI", tipo: "INF", categoria: "SEG",
  correlativo: 23, version: "1.0", fecha-codigo: "20260601",
  titulo: "Título del informe", subtitulo: "Subtítulo · SLEP Chinchorro",
  estado: "BORRADOR", clasificacion: "INTERNO",
  autor: "Nombre Apellido", cargo-autor: "Cargo", correo-autor: "x@epchinchorro.cl",
))
#show: report.with(meta: meta)           // portada + estilos (contraportada al final)

#s-ficha(meta, rama-git: "doc/TI-INF-SEG-2026-0023")   // 1. Ficha de control
#s-versiones((                                          // 2. Control de versiones
  ("v1.0", "2026-06-01", "Nombre Apellido", "Versión inicial."),
))
#s-distribucion((                                       // 3. Distribución
  ("Equipo TI", "Operación documental", "Receptor principal"),
))
#s-indice()                                             // 4. Tabla de contenido

= Resumen ejecutivo
Prosa...

= Antecedentes y motivación
== Contexto institucional
Prosa...
== Problema o necesidad identificada
Prosa...

// ... resto de secciones canónicas (§4) ...

= Recomendaciones
#tabla-prioridad((
  ("1", "Acción recomendada.", "Alta", "Responsable"),
))

= Anexos
== Anexo B. Firmas
#firmas-estandar(meta)
```

La portada y la contraportada se generan automáticamente. No escribas `= Portada` ni `= Contraportada`.

---

## 3. Metadatos (`meta`) — construir SIEMPRE con `crear-meta(...)`

Declara solo lo que cambia; el resto sale de los defaults de la plantilla.

| Clave | Ejemplo | Para qué |
|---|---|---|
| `area` `tipo` `categoria` | `"TI"` `"INF"` `"SEG"` | Código documental (§5) |
| `anio` `correlativo` `version` `fecha-codigo` | `2026` `23` `"1.0"` `"20260601"` | Código documental |
| `tipo-largo` | `"Informe Técnico"` | Rótulo superior de la portada |
| `titulo` `subtitulo` | — | Portada |
| `estado` | `BORRADOR` \| `EN REVISIÓN` \| `APROBADO` | Badge (verde si aprobado) |
| `clasificacion` | `PÚBLICO` \| `INTERNO` \| `RESERVADO` \| `CONFIDENCIAL` | Badge + contraportada |
| `autor` `cargo-autor` `correo-autor` | — | Ficha + firmas (Elaborado) |
| `revisor` `cargo-revisor` | — | Ficha + firmas (Revisado) |
| `aprobador` `cargo-aprob` | — | Ficha + firmas (Aprobado) |
| `contraportada` | `true` (def.) | `false` para omitirla |

Ya vienen por defecto (no repetir salvo cambio): `unidad`, `subdireccion`, `institucion`,
`comunas`, `correo-inst`, `sitio-inst`, `logos.slep`, `logos.isologo`.

---

## 4. Estructura canónica del informe (orden obligatorio, manual §11.1)

| # | Sección | Cómo se genera |
|---|---|---|
| 1 | Portada | automática (`report`) |
| 2 | Ficha de control documental | `#s-ficha(meta, rama-git: ...)` |
| 3 | Control de versiones | `#s-versiones(filas)` |
| 4 | Distribución | `#s-distribucion(filas)` |
| 5 | Tabla de contenido | `#s-indice()` |
| 6 | Resumen ejecutivo | `= Resumen ejecutivo` + prosa |
| 7 | Antecedentes y motivación | `= ...` + `== Contexto institucional` / `== Problema o necesidad identificada` |
| 8 | Objetivo | `= ...` + `== Objetivo general` / `== Objetivos específicos` |
| 9 | Alcance | `= ...` + `== Dentro del alcance` / `== Fuera del alcance` |
| 10 | Marco normativo y referencial | `= ...` + `== Normativa legal aplicable` / `== Estándares técnicos aplicables` |
| 11 | Metodología | `= ...` |
| 12 | Desarrollo técnico | `= ...` (cuerpo principal) |
| 13 | Análisis de impacto | `= ...` + `== Confidencialidad` / `== Integridad` / `== Disponibilidad` |
| 14 | Conclusiones | `= ...` |
| 15 | Recomendaciones | `= ...` + `#tabla-prioridad(...)` |
| 16 | Glosario y acrónimos | `= ...` + `#tabla(...)` |
| 17 | Referencias | `= ...` |
| 18 | Anexos | `= Anexos` + `== Anexo X. ...` (incl. `== Anexo B. Firmas` → `#firmas-estandar(meta)`) |
| 19 | Contraportada | automática (`meta.contraportada`) |

Los encabezados se numeran solos (`1`, `1.1`). Para tipos distintos a INF, adapta las
secciones de prosa conservando ficha, versiones, distribución, firmas y contraportada.

---

## 5. Nomenclatura documental

Patrón: `AREA-TIPO-CAT_AAAA-NNNN_vX.Y_AAAAMMDD` → p. ej. `TI-INF-SEG_2026-0023_v1.0_20260601`.

- `codigo-base(meta)` = `TI-INF-SEG_2026-0023` · `codigo-completo(meta)` = con versión y fecha.
  Se imprimen solos (portada, ficha, footer, contraportada). No los escribas a mano.
- **Tipos:** INF Informe · MAN Manual · POL Política · PRO Procedimiento · PLA Plan · EVL Evaluación · ETT Esp. Técnica · ACT Acta.
- **Categorías (3 letras):** SEG, RED, HRW, SFW, DAT, SRV, PRV, GOB, USR, CPD, BCK, PRY, CAP.

---

## 6. Compilar  (hazlo tras cada edición)

```bash
typst compile nuevo-informe.typ          # → nuevo-informe.pdf
typst watch nuevo-informe.typ            # recompila al guardar (modo redacción)
typst compile --font-path ./fonts nuevo-informe.typ
```

- Requiere **Typst ≥ 0.12** y, para fidelidad tipográfica, la fuente **Museo Sans**
  (si falta, cae a Liberation Sans; el layout no se rompe).
- Coloca los logos reales en `Images/` antes de la versión final (con marcadores los
  recuadros de logo salen vacíos).
- Sin binario, valida con las bindings de Python:
  `pip install typst --break-system-packages && python3 -c "import typst; typst.compile('nuevo-informe.typ', output='out.pdf')"`

---

## 7. API de la plantilla (todo exportado por `lib.typ`)

**Estructura / secciones**
- `crear-meta(dict)` — construye `meta` (defaults + overrides). Úsalo siempre.
- `report` — `#show: report.with(meta:)`. Estilos + portada + contraportada.
- `s-ficha(meta, rama-git: none)` · `s-versiones(filas)` · `s-distribucion(filas)` · `s-indice()`.
- `firmas-estandar(meta)` — firmas tripartitas desde `meta`.

**Componentes**
- `tabla(columns:, headers, rows)` — tabla cebra con cabecera marino.
- `tabla-kv(filas)` — 2 columnas etiqueta/valor (filas = lista de `(clave, valor)`).
- `tabla-prioridad(filas)` — recomendaciones; filas = `(n, recomendación, "Alta"|"Media"|"Baja", responsable)`.
- `ficha-control(meta, rama-git:)` — tabla de la ficha (la usa `s-ficha`).
- `aviso(tipo:, titulo:, cuerpo)` — `tipo` ∈ `"info"` `"advertencia"` `"riesgo"` `"recomendacion"`.
- `firmas(lista de (rol, nombre, cargo))` — firmas personalizadas.
- `indice()` · `badge-estado(s)` · `badge-clasificacion(c)` · `codigo-base/completo(meta)`.

**Tokens de color** (para usos puntuales, no para redefinir el estilo): `marino`, `azul-acento`,
`rojo-acento`, `verde`, `gris-texto`, `gris-borde`, `fondo-label`, `fondo-cebra`, `prio`.

---

## 8. Flujo de co-redacción con el usuario

Cuando el usuario diga “redactemos un informe sobre X”:

1. **Recolecta los metadatos mínimos** que falten: `tipo`/`categoria`, `correlativo`,
   `version`, `fecha-codigo`, `titulo`, y autor/revisor/aprobador. Si el usuario no los da,
   propón valores y confírmalos (no inventes correlativos sin avisar).
2. **Crea el archivo** `TI-<TIPO>-<CAT>_<AAAA>-<NNNN>.typ` con el esqueleto (§2).
3. **Vuelca el contenido del usuario en la estructura canónica** (§4): resumen, antecedentes,
   objetivo, desarrollo, análisis, conclusiones, recomendaciones, anexos. Usa `aviso(...)`
   para destacar estados/riesgos y `tabla(...)`/`tabla-prioridad(...)` para datos.
4. **Compila** (§6) y revisa el PDF; corrige y **itera** con el usuario sección por sección.
5. Al cerrar una versión, actualiza `version`, `fecha-codigo`, agrega fila en `s-versiones`,
   y reporta el `codigo-completo` resultante.

Sugerencia: durante la redacción, deja `typst watch` corriendo para feedback inmediato.

---

## 9. Edge cases

| Síntoma | Causa | Solución |
|---|---|---|
| `dictionary does not contain key "..."` | `meta` parcial pasado a un helper | Construye `meta` con `crear-meta(...)` y pásalo a todos los helpers |
| `file not found (Images/...)` | rutas relativas al documento | Compila desde la carpeta del informe; o ajusta `meta.logos` |
| Recuadros de logo vacíos | faltan los PNG reales | Copia `logoslepch.png` (y `isologo_2.png`) a `Images/` |
| Tipografía distinta al estándar | Museo Sans no instalada | Instálala o usa `--font-path`; fallback Liberation Sans |
| Íconos de aviso como cuadros | la fuente fallback no trae ℹ/⚠/⛔/✓ | Con Museo Sans renderizan; o cambia los glifos en `_aviso-cfg` |
| Correlativo con < 4 dígitos | `correlativo` como string | Pásalo como entero; el padding es automático |
| Portada numerada / doble contraportada | se alteró el flujo de `report` | No edites `report`; no escribas portada/contraportada a mano |

---

## 10. TL;DR para Claude Code

1. No toques el estilo de `lib.typ` sin orden explícita.
2. Un informe = un `.typ` con `crear-meta(...)` + `#show: report.with(meta:)` + secciones canónicas (§4).
3. Usa los atajos `s-ficha / s-versiones / s-distribucion / s-indice / firmas-estandar / tabla-prioridad`.
4. Compila tras cada cambio (§6) y reporta el `codigo-completo`.

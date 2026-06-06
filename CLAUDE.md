# Proyecto: Portal Público We Recruit DR

## Qué es
Portal de empleo público de We Recruit DR. Conecta candidatos dominicanos con empresas que buscan talento. URL en producción: https://www.werecruitdr.com

**Audiencias:**
- **Candidatos:** exploran vacantes activas y aplican directamente desde el portal.
- **Empresas:** conocen los servicios de reclutamiento/headhunting de Svetlana y solicitan servicio.

## Arquitectura
- HTML autocontenido (archivos `.html` con CSS y JS inline, sin frameworks)
- Airtable como base de datos (vacantes, candidatos, empresas)
- Netlify como hosting y despliegue
- Vanilla JS, sin build steps

## Paleta de marca
- Azul oscuro: `#063958` (--dark)
- Azul medio: `#0F6B9F` (--mid)
- Verde menta: `#CEE4CC` (--green)
- Verde oscuro: `#a8c9a4` (--green-dk)
- Crema: `#F5FAF5` (--cream)
- Fondo inputs: `#E2EBE2` (--light)

## Tipografía
- **Nunito** — títulos, logo, CTAs, peso 700–900
- **Open Sans** — cuerpo y texto general, peso 300–600

## Estructura de archivos

```
index (2).html      ← Portal público (vacantes, aplicación, info de empresa)
dashboard (2).html  ← Vista dashboard/admin
README.md
```

## Conexión Airtable

**Base:** `We Recruit DR` — ID: `appswELS9FJd6iGEM`

| Tabla | ID | Uso |
|---|---|---|
| Candidatos | `tblPGc1HFXlXgmXIb` | Registra aplicaciones desde el portal |
| Vacantes | `tbluuQ3gnvKBxqobF` | Vacantes publicadas visibles en el portal |
| Empresas | `tbleoyC1KsRuO0Tvf` | Empresas clientes |

**Campos del formulario de aplicación:**
Nombre, Apellido, Email, Teléfono, Ciudad, LinkedIn, Años de experiencia, Salario esperado (DOP), Carta de motivación (pitch), CV (PDF o Word).

## Reglas de desarrollo
- Todo el código va en archivos HTML autocontenidos. CSS y JS son inline.
- Moneda: solo pesos dominicanos (RD$).
- Los nombres de archivo llevan ` (2)` por versionado — respetar esa convención mientras esté activa.
- Antes de cambiar cualquier componente visual, revisar la paleta y tipografía definidas arriba.
- Si se conecta a Airtable, usar los IDs de tabla, no los nombres (los nombres pueden cambiar).
- El sitio está en español.

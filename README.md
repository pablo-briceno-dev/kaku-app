# Kaku Budget 💰

Kaku Budget es una aplicación de finanzas personales para organizar ingresos, gastos, presupuestos, metas y cuentas desde un solo lugar.

Está diseñada para ser sencilla, flexible y respetuosa con la privacidad: no requiere crear una cuenta y puede utilizarse sin conexión a Internet.

> **Estado:** En desarrollo / preparación para publicación en Google Play.

## ✨ Características

- 📊 **Estadísticas:** consulta y analiza tus ingresos y gastos.
- 💸 **Transacciones:** registra ingresos y gastos con categorías, etiquetas, fechas, importes y demás información asociada.
- 🧾 **Presupuestos:** crea presupuestos por categoría y controla tus límites.
- 🎯 **Metas:** define objetivos financieros y sigue tu progreso.
- 🏦 **Cuentas:** administra diferentes cuentas y sus saldos.
- 🌙 **Modo oscuro.**
- 💱 **Moneda configurable.**
- 🗂️ **Categorías personalizadas.**
- 🏷️ **Etiquetas para transacciones.**
- 📤 **Exportación:** CSV, Excel, PDF y otros formatos disponibles.
- 🎨 **Personalización:** iconos y colores.
- 📚 **Múltiples presupuestos simultáneos.**
- ☁️ **Copias de seguridad y sincronización mediante Google Drive.**
- 🔐 **Protección mediante biometría del dispositivo.**
- 👤 **Sin necesidad de crear una cuenta.**
- 📶 **Funcionamiento sin conexión a Internet.**

## 🛠️ Tecnologías

- Flutter
- Dart
- Riverpod
- Drift
- SQLite
- Material Design

> Mantener esta lista sincronizada con el `pubspec.yaml`.

## 📁 Estructura del proyecto

```text
lib/
├── core/
├── features/
│   ├── accounts/
│   ├── categories/
│   ├── goals/
│   ├── premium/
│   ├── stats/
│   ├── transactions/
│   └── ...
└── shared/
    ├── services/
    ├── utils/
    └── widgets/
```

## 🚀 Instalación

### Requisitos

- Flutter SDK
- Dart SDK incluido con Flutter
- Android Studio / Android SDK
- Visual Studio Code u otro IDE compatible
- Dispositivo físico o emulador

### Clonar

```bash
git clone <URL_DEL_REPOSITORIO>
cd kaku
```

### Instalar dependencias

```bash
flutter pub get
```

### Ejecutar

```bash
flutter run
```

### Analizar

```bash
flutter analyze
```

### Pruebas

```bash
flutter test
```

## 🧪 Pruebas antes de producción

Antes de publicar una versión estable se deben comprobar:

- [ ] Navegación.
- [ ] Registro, edición y eliminación de transacciones.
- [ ] Presupuestos.
- [ ] Metas.
- [ ] Cuentas.
- [ ] Estadísticas.
- [ ] Exportaciones.
- [ ] Copias de seguridad.
- [ ] Restauración de datos.
- [ ] Sincronización con Google Drive.
- [ ] Protección biométrica.
- [ ] Modo oscuro.
- [ ] Diferentes tamaños de pantalla.
- [ ] Orientación vertical y horizontal.
- [ ] Diferentes versiones de Android.
- [ ] Rendimiento y consumo de recursos.

# 📋 Tareas por hacer

## 🔴 Prioridad alta

- [ ] Preparar versión de producción.
- [ ] Completar ficha de Google Play Console.
- [ ] Revisar política de privacidad.
- [ ] Revisar términos y condiciones.
- [ ] Revisar página de soporte.

## 🟡 Prioridad media

- [ ] Mejorar animaciones y transiciones.
- [ ] Revisar accesibilidad.
- [ ] Optimizar rendimiento.
- [ ] Revisar textos y traducciones.
- [ ] Mejorar estados vacíos.
- [ ] Mejorar mensajes de error.
- [ ] Mejorar experiencia de usuario.
- [ ] Añadir más pruebas automatizadas.
- [ ] Revisar dependencias periódicamente.

## 🟢 Mejoras futuras

- [ ] Nuevas opciones de personalización.
- [ ] Nuevos tipos de estadísticas.
- [ ] Nuevas opciones de exportación.
- [ ] Mejoras en presupuestos.
- [ ] Mejoras en metas financieras.
- [ ] Nuevas herramientas de análisis financiero.
- [ ] Evaluar solicitudes de los usuarios.

## 🐛 Problemas conocidos

| Problema | Estado | Prioridad | Notas |
|---|---|---|---|
| — | — | — | No hay problemas registrados actualmente |

## 💡 Ideas futuras

- [ ] Traducción al inglés.

# 📝 Notas de desarrollo

Espacio para registrar decisiones técnicas, cambios de arquitectura, migraciones, problemas encontrados y otra información útil.

### Decisiones actuales

- La aplicación no requiere una cuenta de usuario.
- Está diseñada para funcionar sin conexión.
- Las copias de seguridad pueden realizarse localmente y mediante Google Drive.
- La aplicación puede protegerse mediante biometría.

# 📱 Google Play

**Nombre:** Kaku Budget

**Categoría:** Finanzas

**Modelo:** Aplicación gratuita con compras dentro de la aplicación.

# 🎨 Identidad visual

| Nombre | HEX |
|---|---|
| Background | `#020914` |
| Surface | `#0D1B2A` |
| Teal | `#16B9B2` |
| Mint | `#6CF0D2` |
| Mint Light | `#3DD6C5` |
| Text Primary | `#F5F7FA` |
| Text Secondary | `#A7B4C2` |

El estilo utiliza fondos oscuros, tonos turquesa/menta, elementos luminosos y una estética moderna y limpia.

# 🔒 Privacidad

Kaku Budget está diseñado bajo un enfoque de privacidad.

La aplicación no requiere crear una cuenta y no recopila datos personales para utilizar sus funciones principales.

Los datos financieros se almacenan en el dispositivo y pueden incluirse en copias de seguridad realizadas por el usuario.

La aplicación puede utilizar Google Drive para las funcionalidades de copia de seguridad y sincronización.

> La información definitiva de esta sección debe mantenerse alineada con la política de privacidad publicada y la declaración de seguridad de datos de Google Play Console.

# 💳 Monetización

Kaku Budget se distribuye como una aplicación gratuita y puede incluir compras dentro de la aplicación.

Las funcionalidades Premium y condiciones comerciales deberán documentarse aquí cuando estén definidas.

# 🧑‍💻 Desarrollo

Para comprobar el estado del código:

```bash
flutter analyze
```

Para revisar dependencias:

```bash
flutter pub outdated
```

Para actualizar las dependencias permitidas:

```bash
flutter pub upgrade
```

> Las actualizaciones importantes deben probarse antes de incorporarlas a producción.

# 📦 Versionado

Se recomienda utilizar versionado semántico:

```text
MAJOR.MINOR.PATCH
```

Ejemplos:

```text
1.0.0
1.0.1
1.1.0
2.0.0
```

Los cambios importantes pueden registrarse en un `CHANGELOG.md`.

# 📝 Registro de cambios

## [Unreleased]

### Added
-

### Changed
-

### Fixed
-

### Removed
-

# 💬 Comentarios / pendientes por definir

Esta sección está destinada a información que todavía debe completarse o decisiones que aún no se hayan tomado.

- [ ] Definir licencia definitiva.

### Notas

> Escribe aquí cualquier decisión, problema o tarea que quieras recordar durante el desarrollo.

# 📄 Licencia

La licencia del proyecto está **pendiente de definir**.

```text
[LICENCIA PENDIENTE]
```

---

## ⭐ Kaku Budget

Una aplicación para organizar tus finanzas, controlar tus presupuestos y trabajar hacia tus objetivos financieros.

**Hecho con Flutter ❤️**

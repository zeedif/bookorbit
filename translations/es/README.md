# Traducción al español de BookOrbit

La web se traduce públicamente en [Crowdin](https://crowdin.com/project/bookorbit), en el idioma `es-ES`. La configuración del proyecto solo incluye `client/src/locales/en.json`; el complemento de KOReader no forma parte de esa sincronización.

Esta propuesta parte de `bookorbit/bookorbit` en la revisión `6f8f5f4818eb737dc4d78fc5b5294fc3adb26860`.

## Web

`bookorbit-web-es.po` contiene las 12 460 claves del catálogo inglés, con traducciones completas al español. Incluye las 1784 claves ausentes del catálogo español y corrige 1454 traducciones existentes. Cada entrada conserva su clave en `msgctxt`, el original en `msgid` y la traducción en `msgstr`. Las referencias apuntan al catálogo fuente y, cuando se pudo localizar un uso literal, al código de la interfaz.

El PO sirve para consultar las frases y publicarlas manualmente en Crowdin. El proyecto usa JSON: no se presupone que permita importar directamente un PO como sustituto de su archivo JSON. Para la traducción sin conexión, Crowdin recomienda descargar el XLIFF del propio proyecto y subir ese mismo archivo después de editarlo. El paquete local también incluye `es.json`, con las claves y la estructura originales.

Los plurales ICU permanecen dentro de una sola cadena. Deben conservarse los nombres de los argumentos, los selectores exactos como `=0` y las ramas de plural. Los plurales del plugin, en cambio, usan `msgid_plural` y dos `msgstr` de gettext.

La aplicación web conserva sus catálogos administrados por Crowdin. Este fork añade el archivo de intercambio fuera de `client/src/locales/`.

## Complemento de KOReader

El catálogo `koreader-plugin/bookorbit.koplugin/l10n/es.po` contiene 1322 entradas, incluidas las formas plurales, los meses usados mediante una llamada dinámica, ocho nombres de idiomas que antes no pasaban por gettext y cuatro contextos adicionales.

El complemento usa el catálogo español cuando el idioma de KOReader es `es` o una variante como `es_ES` o `es-MX`. Los demás idiomas y las cadenas desconocidas siguen usando el gettext de KOReader. El catálogo se carga una sola vez y no modifica las traducciones globales de KOReader.

La integración distingue «Read» como acción («Leer»), estado («Leído»), filtro («Leídos») y criterio de ordenación («Última lectura»). También separa la fecha que recibe mes y día para mostrar día y mes en español.

Para instalarlo, copia la carpeta `bookorbit.koplugin` de esta rama en `koreader/plugins/`, configura KOReader en español y reinícialo. La descarga local `bookorbit-koreader-es.zip` contiene esa misma carpeta, sin credenciales. Los datos y las credenciales se configuran como en el complemento original.

Si actualizas el complemento desde un servidor BookOrbit que use el código original, ese servidor volverá a entregar su versión sin este catálogo. Para conservar la traducción, usa el código de este fork en el servidor o reinstala el paquete español después de actualizar.

Después de editar el PO, regenera el catálogo de ejecución con Node:

```sh
node koreader-plugin/tools/compile_catalog.mjs
node koreader-plugin/tools/compile_catalog.mjs --check
node --test koreader-plugin/tools/compile_catalog.test.mjs
```

El compilador no requiere dependencias adicionales. Admite el PO UTF-8 generado en esta propuesta, sus cadenas multilínea, contextos y plurales españoles. Omite las sugerencias marcadas como `fuzzy` y rechaza traducciones vacías, mensajes duplicados y plurales incompletos.

## Criterios lingüísticos

- Tratamiento de tú y acciones expresadas con infinitivos en los botones.
- Títulos y etiquetas en estilo oración; mayúsculas para nombres propios, marcas y siglas.
- Punto final en explicaciones y ayudas completas. Las etiquetas breves, los fragmentos que rodean enlaces y los campos de formulario conservan la puntuación adecuada a su función.
- Fechas y abreviaturas españolas; espacio antes de `%` y entre cantidades y unidades.
- Conservación de rutas, identificadores, variables, direcciones de ejemplo y órdenes literales. Por ejemplo, el asunto de Kindle sigue siendo `convert` y la ruta del complemento sigue siendo `koreader/plugins/`.
- Uso contextual del diccionario personal facilitado para la traducción. No se publica aquí el archivo del diccionario.

| Original                | Traducción preferida y contexto                                                                           |
| ----------------------- | --------------------------------------------------------------------------------------------------------- |
| book / library          | libro / biblioteca                                                                                        |
| shelf / collection      | estante / colección                                                                                       |
| cover                   | cubierta de libro, alternativa recogida en el diccionario; «cobertura» se reserva para otros significados |
| highlight               | resaltado de texto; «destacado» para un elemento destacado de la interfaz                                 |
| bookmark / annotation   | marcador / anotación                                                                                      |
| settings / setup        | ajustes / configuración inicial o puesta en marcha                                                        |
| merge / link            | combinar registros y archivos / vincular libros que conservan su identidad                                |
| default                 | predeterminado, con la concordancia correspondiente                                                       |
| fetch / upload          | obtener / subir                                                                                           |
| enable / disable        | habilitar / desactivar                                                                                    |
| rating / review         | puntuación / reseña, según corresponda                                                                    |
| plugin / dashboard      | complemento / panel                                                                                       |
| read-aloud / read-along | lectura con audio sincronizado, cuando alinea una narración existente con el EPUB                         |
| text-to-speech          | síntesis de voz                                                                                           |
| SmartScope / Book Dock  | nombres de las funciones conservados                                                                      |

La revisión contrastó claves, frases repetidas, referencias al código y mensajes de operaciones sensibles. No sustituye la comprobación visual de cada pantalla en todos los tamaños de dispositivo. No se han enviado traducciones a Crowdin ni se ha abierto una solicitud de cambios al proyecto original.

Referencias: [flujo de localización de BookOrbit](https://github.com/bookorbit/bookorbit/blob/main/docs/LOCALIZATION.md), [traducción sin conexión en Crowdin](https://support.crowdin.com/offline-translation/) y [carga de traducciones existentes](https://support.crowdin.com/uploading-translations/).

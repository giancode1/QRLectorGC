# QRLectorGC

Lector de códigos QR para macOS que vive en la **barra de menú**. Haz clic en el ícono, arrastra un rectángulo sobre cualquier QR que tengas en pantalla y la app te muestra su contenido para copiarlo. Swift + AppKit, sin dependencias.

## Uso

1. **Clic** en el ícono de la barra de menú (o clic derecho / `⌃`-clic › *Iniciar Scan*).
2. Arrastra un rectángulo alrededor del código QR.
3. Aparece el contenido en un diálogo con el botón **Copiar**. Si no hay ningún QR en esa zona, avisa con «Sin resultado».

La app no tiene ícono en el Dock; para salir usa el menú del ícono › *Salir*.

## Instalar (sin Xcode)

Requisitos: **macOS 13 o superior** (Intel o Apple Silicon). No hace falta Xcode ni Swift.

1. Descarga [`QRLectorGC-macOS.zip`](https://github.com/giancode1/QRLectorGC/releases/latest/download/QRLectorGC-macOS.zip) desde [Releases](https://github.com/giancode1/QRLectorGC/releases/latest).
2. Descomprímelo y mueve `QRLectorGC.app` a *Aplicaciones*.
3. La primera vez macOS la bloqueará porque no está notarizada por Apple: clic derecho sobre la app › *Abrir* (en macOS 15: *Ajustes del Sistema › Privacidad y seguridad › Abrir de todos modos*). También sirve en Terminal: `xattr -dr com.apple.quarantine /Applications/QRLectorGC.app`.
4. Al primer escaneo, macOS pide el permiso de **Grabación de pantalla**: concédelo en *Ajustes del Sistema › Privacidad y seguridad › Grabación de pantalla*.

## Compilar desde el código

Requisitos: macOS 13+ y **Xcode o Command Line Tools** (Swift 5.9+).

```bash
./build.sh
open QRLectorGC.app
```

`build.sh` firma la app con tu certificado *Apple Development* si lo encuentra (así macOS recuerda el permiso de pantalla entre compilaciones) y, si no, usa firma ad-hoc.

## Notas

- Solo escanea la pantalla principal.
- Usa `CGWindowListCreateImage`, deprecada desde macOS 14 pero funcional; si Apple la retira, hay que migrar a ScreenCaptureKit.

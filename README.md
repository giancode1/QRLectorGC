# QRLectorGC

Lector de códigos QR para macOS que vive en la **barra de menú**. Haz clic en el ícono, arrastra un rectángulo sobre cualquier QR que tengas en pantalla y la app te muestra su contenido para copiarlo. Swift + AppKit, sin dependencias.

## Uso

1. **Clic** en el ícono de la barra de menú (o clic derecho / `⌃`-clic › *Iniciar Scan*).
2. Arrastra un rectángulo alrededor del código QR.
3. Aparece el contenido en un diálogo con el botón **Copiar**. Si no hay ningún QR en esa zona, avisa con «Sin resultado».

La app no tiene ícono en el Dock; para salir usa el menú del ícono › *Salir*.

## Requisitos

- macOS 13 o superior.
- Swift 5.9+ (Xcode o Command Line Tools).
- Permiso de **Grabación de pantalla** para la app (macOS lo pide en el primer scan).

## Compilar y abrir

```bash
./build.sh
open QRLectorGC.app
```

`build.sh` firma la app con tu certificado *Apple Development* si lo encuentra (así macOS recuerda el permiso de pantalla entre compilaciones). Sin certificado usa firma ad-hoc y habrá que volver a otorgar el permiso en cada compilación.

## Notas

- Solo escanea la pantalla principal.
- Usa `CGWindowListCreateImage`, deprecada desde macOS 14 pero funcional; si Apple la retira, hay que migrar a ScreenCaptureKit.

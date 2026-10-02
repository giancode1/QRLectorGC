#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release

APP="QRLectorGC.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
cp "$(swift build -c release --show-bin-path)/QRLectorGC" "$APP/Contents/MacOS/QRLectorGC"
cp Resources/Info.plist "$APP/Contents/Info.plist"

# Firma con una identidad real (no ad-hoc): con "--sign -" el hash de firma
# cambia en cada build y macOS pide de nuevo el permiso de Screen Recording
# cada vez. Con una identidad de Apple Development (gratis, la crea Xcode
# al iniciar sesión con tu Apple ID) el permiso persiste entre builds.
SIGN_ID=$(security find-identity -v -p codesigning | grep -m1 "Apple Development" | sed -E 's/.*"(.*)"/\1/')
if [ -z "$SIGN_ID" ]; then
    echo "Aviso: no se encontró una identidad 'Apple Development', firmando ad-hoc (el permiso de Screen Recording habrá que re-otorgarlo en cada build)."
    codesign --force --deep --sign - "$APP"
else
    codesign --force --deep --sign "$SIGN_ID" "$APP"
fi

echo "Listo: $APP  (muévela a /Applications y ábrela con doble clic)"

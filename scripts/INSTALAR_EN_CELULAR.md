# Probar la app en un celular real

## Android

### 1. Prepara la configuracion del instalador

1. Copia el ejemplo:

```powershell
Copy-Item .\scripts\android_installer.config.example.json .\scripts\android_installer.config.json
```

2. Edita `scripts\android_installer.config.json` y completa:

- `apiBaseUrl`
  Debe ser una URL real que el celular pueda abrir por Wi-Fi o internet.
  No uses `localhost` ni `10.0.2.2` para un telefono fisico.

### 2. Genera el APK instalable

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_android_installer.ps1
```

El script valida que:

- `API_BASE_URL` exista y no apunte a `localhost`

Si prefieres pasar los valores por linea de comandos, tambien puedes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\build_android_installer.ps1 `
  -ApiBaseUrl http://192.168.1.50/appfitness_api
```

### 3. Resultado del build

El instalador queda en:

```text
dist\appfitness-android-release.apk
```

Y el resumen del build en:

```text
dist\appfitness-android-release.build-info.txt
```

### 4. Instalar en el telefono

Puedes instalarlo de dos maneras:

- Copiando ese `.apk` al telefono y abriendolo desde el explorador de archivos.
- Por cable USB con depuracion activada:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install_android_release.ps1
```

## iPhone

En esta computadora Windows no se puede generar un `.ipa` instalable para iPhone porque Apple exige `Xcode` y firma de codigo en macOS.

Para probarla en un iPhone real:

1. Abre este mismo proyecto en una Mac.
2. Instala Flutter y Xcode.
3. Abre `ios/Runner.xcworkspace` en Xcode.
4. En `Signing & Capabilities`, elige tu cuenta Apple.
5. Cambia el `Bundle Identifier` por uno unico si hace falta.
6. Ejecuta desde Xcode con `API_BASE_URL`.

Si quieres distribuirla a otros iPhones, el siguiente paso es generar un `.ipa` desde Xcode y subirlo por `TestFlight`.

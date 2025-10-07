# 🎯 Guía de instalación del proyecto Flutter

Este proyecto utiliza Flutter e incluye dependencias para reconocimiento de voz, base de datos local y manejo de permisos.  
Sigue los pasos a continuación para configurarlo correctamente.

## 🧩 1. Clonar el proyecto

Primero, clona este repositorio dentro de tu entorno Flutter:

git clone https://github.com/usuario/tu_proyecto.git
cd tu_proyecto
📦 2. Instalar dependencias
Ejecuta los siguientes comandos en la terminal dentro del proyecto:


flutter pub add cupertino_icons
flutter pub add speech_to_text
flutter pub add sqflite
flutter pub add path_provider
flutter pub add provider
flutter pub add flutter_speed_dial
flutter pub add permission_handler
💡 Si ocurre algún error o las dependencias no se actualizan, edita manualmente el archivo pubspec.yaml y luego ejecuta:

flutter pub get
⚙️ 3. Configuración del AndroidManifest
Abre el archivo:

android/app/src/main/AndroidManifest.xml
y asegúrate de agregar los siguientes permisos a nivel del <application>, tal como se muestra a continuación:


<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:name="${applicationName}"
        android:label="tu_proyecto"
        android:icon="@mipmap/ic_launcher">
        ...
    </application>

    <queries>
        ...
    </queries>

    <!-- Permisos necesarios -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.INTERNET" />

</manifest>
⚠️ Nota: Algunos IDE pueden sugerir mover los permisos justo debajo de <manifest>, lo cual también es válido.

▶️ 4. Ejecutar el proyecto
Para ejecutar la aplicación en un emulador o dispositivo físico, usa:

flutter run
Si deseas compilar el APK para producción:

flutter build apk

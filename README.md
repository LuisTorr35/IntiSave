Clonar en un proyecto flutter.
Instalar lo siguiente
flutter pub add cupertino_icons
flutter pub add speech_to_text
flutter pub add sqflite
flutter pub add path_provider
flutter pub add provider
flutter pub add flutter_speed_dial
flutter pub add permission_handler
Si no funciona actualizar el pubspec.yaml

En el AndroidManifest colocar lo siguiente. A nivel de Application
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
   <application
   ...
   </application>
   <queries>
   ..
   </queries>
   <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   <uses-permission android:name="android.permission.INTERNET"/>
</manifest>

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:intisave/db/database_helper.dart';
class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = "Presiona el micrófono y habla...";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }
  Future<void> _procesarTexto(String texto) async {
    texto = texto.toLowerCase();

    String tipo = "gasto"; // por defecto
    double monto = 0;
    String categoria = "Otros";

    // --- Detectar tipo (gasto o ingreso) ---
    if (texto.contains("gaste") ||
        texto.contains("gasté") ||
        texto.contains("pagué") ||
        texto.contains("compré") ||
        texto.contains("invertí") ||
        texto.contains("saqué")) {
      tipo = "Gasto";
    } else if (texto.contains("me dieron") ||
        texto.contains("me pagaron") ||
        texto.contains("cobré") ||
        texto.contains("gané") ||
        texto.contains("recibí") ||
        texto.contains("encontré") ||
        texto.contains("vendí") ||
        texto.contains("ahorré") ||
        texto.contains("deposité")) {
      tipo = "Ingreso";
    }

    // --- Detectar monto ---
    RegExp regExp = RegExp(r'\d+(?:[\.,]\d+)?'); // acepta decimales
    var match = regExp.firstMatch(texto);
    if (match != null) {
      monto = double.parse(match.group(0)!.replaceAll(',', '.'));
    }

    // --- Mapa ampliado de categorías ---
    final Map<String, String> categoriasMap = {
      // Transporte
      "taxi": "Transporte",
      "bus": "Transporte",
      "micro": "Transporte",
      "gasolina": "Transporte",
      "combustible": "Transporte",
      "pasaje": "Transporte",
      "movilidad": "Transporte",

      // Comida
      "almuerzo": "Comida",
      "desayuno": "Comida",
      "cena": "Comida",
      "pollo": "Comida",
      "hamburguesa": "Comida",
      "pizza": "Comida",
      "menú": "Comida",
      "restaurante": "Comida",
      "snack": "Comida",

      // Salud
      "medicina": "Salud",
      "doctor": "Salud",
      "clínica": "Salud",
      "hospital": "Salud",
      "pastilla": "Salud",

      // Limpieza
      "detergente": "Limpieza",
      "jabón": "Limpieza",
      "limpiador": "Limpieza",
      "escoba": "Limpieza",
      "lejía": "Limpieza",

      // Vivienda
      "alquiler": "Vivienda",
      "renta": "Vivienda",
      "luz": "Vivienda",
      "agua": "Vivienda",
      "internet": "Servicios",
      "servicio": "Servicios",

      // Educación
      "colegio": "Educación",
      "universidad": "Educación",
      "curso": "Educación",
      "libro": "Educación",
      "útiles": "Educación",

      // Entretenimiento
      "cine": "Entretenimiento",
      "juego": "Entretenimiento",
      "videojuego": "Entretenimiento",
      "película": "Entretenimiento",
      "fiesta": "Entretenimiento",
      "cerveza": "Entretenimiento",

      // Ropa
      "pantalón": "Ropa",
      "camisa": "Ropa",
      "zapato": "Ropa",
      "ropa": "Ropa",

      // Ingresos
      "sueldo": "Sueldo",
      "salario": "Sueldo",
      "regalo": "Regalo",
      "premio": "Regalo",
      "venta": "Otros",
      "ahorro": "Otros",
      "me encontré": "Otros",
    };

    // --- Detectar categoría ---
    categoriasMap.forEach((key, value) {
      if (texto.contains(key)) {
        categoria = value;
      }
    });

    // --- Validación ---
    if (monto == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se detectó monto en la frase.")),
      );
      return;
    }

    // --- Mostrar resultado provisional ---
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Detectado: $tipo | S/. $monto | $categoria")),
    );

    // --- Guardar en la base de datos ---
    await DatabaseHelper.instance.registrarAhorro(
      1, // usuario_id
      tipo,
      categoria,
      monto,
      texto,
    );
  }

  void _listen() async {
    var status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permiso de micrófono denegado"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print("Estado: $val"),
        onError: (val) => print("Error: $val"),
      );

      if (available) {
        setState(() => _isListening = true);

        _speech.listen(
          onResult: (val) async {
            setState(() {
              _recognizedText = val.recognizedWords;
            });

            // Solo procesar una vez, cuando se finaliza la frase
            if (val.finalResult && val.recognizedWords.isNotEmpty) {
              await _procesarTexto(val.recognizedWords);
              setState(() => _isListening = false);
              _speech.stop();
            }
          },
          localeId: "es_PE",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se pudo acceder al micrófono"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ingreso por voz"),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Center(
        child: Text(
          _recognizedText,
          style: const TextStyle(fontSize: 20, color: Colors.black87),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B0000),
        onPressed: _listen,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

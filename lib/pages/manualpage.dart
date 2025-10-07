import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ManualPage extends StatefulWidget {
  const ManualPage({super.key});

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  String? _categoriaSeleccionada;
  String _tipo = "Gasto";

  // Categorías de gasto
  final List<String> categoriasGasto = [
    "Comida",
    "Transporte",
    "Salud",
    "Limpieza",
    "Educación",
    "Entretenimiento",
    "Ropa",
    "Servicios",
    "Vivienda",
    "Otros"
  ];

  // Categorías de ingreso
  final List<String> categoriasIngreso = [
    "Sueldo",
    "Regalo",
    "Otros"
  ];

  void _guardarRegistro() async {
    if (_montoController.text.isEmpty || _categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe ingresar monto y categoría")),
      );
      return;
    }

    await DatabaseHelper.instance.registrarAhorro(
      1, // usuario por defecto
      _tipo,
      _categoriaSeleccionada!,
      double.parse(_montoController.text),
      _descripcionController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$_tipo registrado correctamente")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    // Lista dinámica según tipo
    List<String> categorias = _tipo == "Ingreso" ? categoriasIngreso : categoriasGasto;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro Manual"),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(
                labelText: "Tipo",
                border: OutlineInputBorder(),
              ),
              items: ["Ingreso", "Gasto"]
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _tipo = value!;
                  _categoriaSeleccionada = null; // resetear categoría
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Monto",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoriaSeleccionada,
              decoration: const InputDecoration(
                labelText: "Categoría",
                border: OutlineInputBorder(),
              ),
              items: categorias
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _categoriaSeleccionada = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: _guardarRegistro,
              child: const Text(
                "Guardar",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

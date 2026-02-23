import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/premio_provider.dart';
import 'package:nfc/widgets/common/app_button.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';

class PremioCreateScreen extends ConsumerStatefulWidget {
  const PremioCreateScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PremioCreateScreen> createState() => _PremioCreateScreenState();
}

class _PremioCreateScreenState extends ConsumerState<PremioCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _puntosController = TextEditingController();
  final _iconoController = TextEditingController();

  @override
  void dispose() {
    _tituloController.dispose();
    _puntosController.dispose();
    _iconoController.dispose();
    super.dispose();
  }

  Future<void> _crearPremio() async {
    if (_formKey.currentState!.validate()) {
      final titulo = _tituloController.text;
      final puntos = int.parse(_puntosController.text);
      final icono = _iconoController.text;

      try {
        final service = ref.read(premioServiceProvider);
        await service.create(
          titulo: titulo,
          costoPuntos: puntos,
          icono: icono,
        );
        
        // Invalidar la lista de premios después de crear
        ref.invalidate(premioListProvider);
        
        if (mounted) {
          SuccessSnackBar.show(context, message: 'Premio creado');
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ErrorDialog.show(context, message: e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Premio')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _puntosController,
                decoration: const InputDecoration(
                  labelText: 'Puntos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce los puntos';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Introduce un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _iconoController,
                decoration: const InputDecoration(
                  labelText: 'Icono',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un icono';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              AppButton(label: 'Crear Premio', onPressed: _crearPremio),
            ],
          ),
        ),
      ),
    );
  }
}

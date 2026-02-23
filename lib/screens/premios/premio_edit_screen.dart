import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/premio_provider.dart';
import 'package:nfc/widgets/common/app_button.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';

class PremioEditScreen extends ConsumerStatefulWidget {
  const PremioEditScreen({Key? key, required this.premioId}) : super(key: key);
  final String premioId;

  @override
  ConsumerState<PremioEditScreen> createState() => _PremioEditScreenState();
}

class _PremioEditScreenState extends ConsumerState<PremioEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _puntosController = TextEditingController();
  final _iconoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(premioDetailProvider(widget.premioId).future).then((premio) {
      if (premio != null) {
        _tituloController.text = premio['titulo'] as String;
        _puntosController.text = (premio['puntos_costo'] as int).toString();
        _iconoController.text = premio['icono'] as String? ?? '🎁';
      }
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _puntosController.dispose();
    _iconoController.dispose();
    super.dispose();
  }

  Future<void> _editarPremio() async {
    if (_formKey.currentState!.validate()) {
      final titulo = _tituloController.text;
      final puntos = int.parse(_puntosController.text);
      final icono = _iconoController.text;

      try {
        final service = ref.read(premioServiceProvider);
        await service.update(
          id: widget.premioId,
          titulo: titulo,
          costoPuntos: puntos,
          icono: icono,
        );
        
        // Invalidar el detalle y lista después de actualizar
        ref.invalidate(premioDetailProvider(widget.premioId));
        ref.invalidate(premioListProvider);
        
        if (mounted) {
          SuccessSnackBar.show(context, message: 'Premio actualizado');
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
    final premioAsync = ref.watch(premioDetailProvider(widget.premioId));

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Premio')),
      body: premioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (premio) {
          if (premio == null) {
            return const Center(child: Text('Premio no encontrado'));
          }
          return Form(
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
                  AppButton(
                    label: 'Actualizar Premio',
                    onPressed: _editarPremio,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc/providers/nino_provider.dart';
import 'package:nfc/widgets/common/app_button.dart';
import 'package:nfc/widgets/common/app_dialogs.dart';

class NinoEditScreen extends ConsumerStatefulWidget {
  const NinoEditScreen({Key? key, required this.ninoId}) : super(key: key);
  final String ninoId;

  @override
  ConsumerState<NinoEditScreen> createState() => _NinoEditScreenState();
}

class _NinoEditScreenState extends ConsumerState<NinoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _nfcUidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(ninoDetailProvider(widget.ninoId).future).then((nino) {
      if (nino != null) {
        _nombreController.text = nino['nombre'] as String;
        _nfcUidController.text = nino['nfc_uid'] as String? ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nfcUidController.dispose();
    super.dispose();
  }

  Future<void> _editarNino() async {
    if (_formKey.currentState!.validate()) {
      final nombre = _nombreController.text;
      final nfcUid = _nfcUidController.text;

      try {
        final service = ref.read(ninoServiceProvider);
        await service.update(
          id: widget.ninoId,
          nombre: nombre,
          nfcUid: nfcUid,
        );
        
        // Invalidar el detalle y lista después de actualizar
        ref.invalidate(ninoDetailProvider(widget.ninoId));
        ref.invalidate(ninoListProvider);
        
        if (mounted) {
          SuccessSnackBar.show(context, message: 'Niño actualizado');
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
    final ninoAsync = ref.watch(ninoDetailProvider(widget.ninoId));

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Niño')),
      body: ninoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (nino) {
          if (nino == null) {
            return const Center(child: Text('Niño no encontrado'));
          }
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, introduce un nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nfcUidController,
                    decoration: const InputDecoration(
                      labelText: 'NFC UID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  AppButton(label: 'Actualizar Niño', onPressed: _editarNino),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
